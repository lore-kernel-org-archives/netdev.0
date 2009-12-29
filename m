From: Fabio Ludovici <fabio.ludovici@yahoo.it>
Subject: Re: [RESEND PATCH 3/3] netem/iproute2 solving correlated loss issue
Date: Tue, 29 Dec 2009 21:02:11 +0100
Message-ID: <4B3A6043.5060803@yahoo.it>
References: <4B3A5F84.4050603@yahoo.it>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f225.google.com ([209.85.220.225]:62946 "EHLO
	mail-fx0-f225.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752133AbZL2UCT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Dec 2009 15:02:19 -0500
Received: by fxm25 with SMTP id 25so5511310fxm.21
        for <netdev@vger.kernel.org>; Tue, 29 Dec 2009 12:02:17 -0800 (PST)
In-Reply-To: <4B3A5F84.4050603@yahoo.it>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

man page for iproute2/netem, including all the existing documentation 
and the latest features:

- deterministic loss generation according to a pattern that can be 
specified in a file in the iproute2 command line
- new statistical models for generation of correlated loss (the existing 
model does not work), including loss models commonly used in literature 
(bernoulli, Gilbert, Gilbert Elliot) and the new GI (General and 
Intuitive) model
- parameter converter between intuitive parameters and Markov transition 
probabilities (query mode)
- enhanced logging functionality for loss events in dmesg

Signed-off-by: Stefano Salsano <stefano.salsano@uniroma2.it>
Signed-off-by: Fabio Ludovici <fabio.ludovici@yahoo.it>
---
  man/man8/tc-netem.8 |  225 
+++++++++++++++++++++++++++++++++++++++++++++++++++
  1 files changed, 225 insertions(+), 0 deletions(-)
  create mode 100644 man/man8/tc-netem.8

diff --git a/man/man8/tc-netem.8 b/man/man8/tc-netem.8
new file mode 100644
index 0000000..4fbe579
--- /dev/null
+++ b/man/man8/tc-netem.8
@@ -0,0 +1,225 @@
+.TH NETEM 8 "28 December 2009" "iproute2" "Linux"
+.SH NAME
+NetEm \- Network Emulator
+.SH SYNOPSIS
+.B tc qdisc ... dev
+dev
+.B ] add netem  [ limit
+packets
+.B ]
+
+.B tc qdisc ... dev
+dev
+.B ] add netem [ logging
+LEVEL ]
+.B ]
+
+.B tc qdisc ... dev
+dev
+.B ] add netem [ delay
+TIME [ JITTER [CORRELATION]]]
+.B ]
+
+.B tc qdisc ... dev
+dev
+.B ] add netem [ distribution
+{uniform|normal|pareto|paretonormal} ]
+.B ]
+
+.B tc qdisc ... dev
+dev
+.B ] add netem [ drop
+PERCENT [CORRELATION]]
+.B ]
+
+.B tc qdisc ... dev
+dev
+.B ] add netem [ loss
+PERCENT [CORRELATION]]
+.B ]
+
+.B tc qdisc ... dev
+dev
+.B ] add netem  [ query
+]
+
+.B tc qdisc ... dev
+dev
+.B ] add netem [ loss_GI
+ploss [burst_length [density [pisol [good_burst_length]]]]
+.B ]
+
+.B tc qdisc ... dev
+dev
+.B ] add netem [ loss_GI_tran
+p13 p31 [p32 p23 [p14]]
+.B ]
+
+.B tc qdisc ... dev
+dev
+.B ] add netem  [ loss_bern
+p
+.B ]
+
+.B tc qdisc ... dev
+dev
+.B ] add netem  [ loss_gilb
+p r [1-h]]
+.B ]
+
+.B tc qdisc ... dev
+dev
+.B ] add netem  [ loss_gilbell
+p r [1-h [1-k]]
+.B ]
+
+.B tc qdisc ... dev
+dev
+.B ] add netem [ loss_pattern
+FILENAME [REPETITIONS]]
+.B ]
+
+.B tc qdisc ... dev
+dev
+.B ] add netem  [ corrupt
+PERCENT [CORRELATION]]
+.B ]
+
+.B tc qdisc ... dev
+dev
+.B ] add netem  [ duplicate
+PERCENT [CORRELATION]]
+.B ]
+
+.B tc qdisc ... dev
+dev
+.B ] add netem  [ reorder
+PRECENT [CORRELATION] [ gap DISTANCE ]]
+.B ]
+
+.SH DESCRIPTION
+NetEm is an enhancment of the Linux traffic control facilities
+that allow to add delay, packet loss, duplication and more other
+characteristics to packets outgoing from a selected network
+interface. NetEm is build using the existing Quality Of Service (QOS)
+and Differentiated Services (diffserv) facilities in the Linux
+kernel.
+
+.SH netem OPTIONS
+netem has the following options:
+
+.B limit
+packets
+
+limits the effect of selected options to the indicated number of next 
packets.
+
+.B logging
+LEVEL
+
+sets a logging level. Actually it works with loss_GI, loss_GI_tran, 
loss_bern, loss_gilb, loss_gilbell, loss_pattern options. If not 
specified, level 0 will be used, then no data will be logged. When 
logging level is set to 1 the kernel logs will include, for each loss 
event, a line like "netem loss event algorithm [type] x RFPLE y" where 
RFPLE stands for "Received From Previous Loss Event" and it counts the 
number y of good packets received between two loss events while x is the 
number of all lost packets and algorithm refers to the selected loss 
generation algorithm (GI, gilbell or deterministic). The type label 
applies only to the GI algorithm and can be burst or isolated.
+
+.B delay
+TIME [ JITTER [CORRELATION]]]
+
+adds the chosen delay to the packets outgoing to chosen network 
interface. The optional parameters allows to introduce a delay variation 
and a correlation. Delay and jitter values are expressed in ms while 
correlation is percentage.
+
+.B distribution
+{uniform|normal|pareto|paretonormal}
+
+allow the choose the delay distribution. If not specified, the default 
distribution is normal. Additional parameters allow to consider 
situations in which network has variable delays depending on traffic 
flows concurring on the same path, that causes severeal delay peaks and 
a tail.
+
+.B drop
+PERCENT [CORRELATION]
+
+OR
+
+.B loss
+PERCENT [CORRELATION]
+
+using drop or loss is the same. It adds the chosen independent loss 
probability to packets outgoing from the chosen network interface. It is 
also possibile to add a correlation, through the proper parameter. 
However this option is now deprecated due to the noticed bad behaviour. 
To have introduce independent packet losses, which corresponds to the 
Bernoulli loss model, please use the loss_bern option.
+
+.B query
+
+enables the query mode. It works with loss_GI, loss_GI_tran, loss_bern, 
loss_gilb, loss_gilbell options. When the query mode is enabled and one 
of the supported options are selected, the correspondent transition 
probabilities and GI parameters are calculated and printed to screen 
without passing the parameters to the qdisc. So this option works like a 
parameters converter. If the option is not specified the query mode will 
be disabled, then the parameters will be regularly passed to the netem 
qdisc.
+
+.B loss_GI
+ploss [burst_length [density [pisol [good_burst_length]]]]
+
+adds packet losses according to the GI (General and Intuitive) loss 
model, using the intuitive parameters. The parameter ploss  is mandatory 
and if used alone corresponds to the Bernoulli model while the optional 
parameters allows to extend the model to 2-state (burst_length), 3-state 
(density), and 4-state (pisol). If the good_burst_length is not 
specified the hyphotesis of statistical independence for the losses 
within the burst will be used.
+
+.B loss_GI_tran
+p13 p31 [p32 p23 [p14]]
+
+adds packet losses according to the GI (General and Intuitive) loss 
model, using the 4-state Markov transition probabilities as input 
parameters. The first two parameters p13 and p31 are mandatory and if 
used alone corresponds to a 2-state model while the optional parameters 
allows to extend the model to 3-state (p23 and p32) and 4-state (p14). 
State 1 corresponds to good reception, State 4 to independent losses, 
State 3 to burst losses and State 2 to good reception within a burst.
+
+.B loss_bern
+p
+
+adds packet losses according to the Bernoulli loss model. Allows to 
introduce, through the p parameter, an independent loss probability to 
packets outgoing from chosen network interface. This option is 
equivalent to the now deprecated drop / loss
+option used without the correlation parameter.
+
+.B loss_gilb
+p r [1-h]
+
+adds packet losses according to the Gilbert loss model through the two 
mandatory parameters p and r and the optional 1-h. This model has two 
states: "good" and "bad". If only the mandatory parameters are 
specified, the Simple Gilbert model will be used, while to use the full 
Gilbert model it is needed to specify the whole set of three parameters.
+
+.B loss_gilbell
+p r [1-h [1-k]]
+
+adds packet losses according to the Gilbert-Elliot loss model through 
the two mandatory parameters p and r and the optional 1-h and 1-k where  
1-k is an independent loss probability in the "good" state while 1-h is 
the loss density within the "bad" state. This model is a more general 
version of the Gilbert model.
+
+.B loss_pattern
+FILENAME [REPETITIONS]
+
+adds packet losses according to a deterministic loss pattern. It reads 
from the text file FILENAME a sequence of "1" and "0" where "1" are the 
loss events and "0" are the regular transmission of packets . The 
parameter repetitions is optional and is the number of "replicas" of the 
loss pattern file. It is optional and by default is 0 which means 
infinite repetition of the loss pattern.
+
+.B corrupt
+PERCENT [CORRELATION]]
+
+allows the emulate the random noise introducing an error in a random 
position for a chosen percent of packets. It is also possible to add a 
correlation through the proper parameter.
+
+.B duplicate
+PERCENT [CORRELATION]]
+
+using this option the chosen percent of packets is duplicated before 
queueing them. It is also possible to add a correlation through the 
proper parameter.
+
+.B reorder
+PRECENT [CORRELATION] [ gap DISTANCE ]]
+
+there are two ways to use this option:
+
+.B reorder
+gap 5 10 ms
+
+in this first example every 5th (10th, 15th) packet is sent immediately 
while other packets are delayed by 10 ms
+
+.B reorder
+25% 50%
+
+in this second example 25% of packets are sent immediately (with 
correlation of 50%) while the other are delayed by 10 ms.
+
+.SH LIMITATIONS
+The main known limitation of Netem are related to timer granularity, 
since Linux is not a real-time operating system; to the choice of 
Pseudo-Random Number Generator (PRNG) and the original loss model.
+
+.SH SOURCES
+.TP
+o
+Hemminger S. , "Network Emulation with NetEm", Open Source Development 
Lab, April 2005 
(http://devresources.linux-foundation.org/shemminger/netem/LCA2005_paper.pdf) 

+
+.TP
+o
+Netem page from Linux foundation, 
(http://www.linuxfoundation.org/en/Net:Netem)
+
+.TP
+o
+Salsano S., Ludovici F., Ordine A., "Definition of a general and 
intuitive loss model for packet
+networks and its implementation in the Netem module in the Linux 
kernel", 
(http://netgroup.uniroma2.it/twiki/pub/Main/netem2/TR-loss-netem.pdf)
+
+
+.SH SEE ALSO
+.BR tc (8)
+
+.SH AUTHOR
+Netem was written by Stephen Hemminger at OSDL and is based on NISTnet. 
This manpage was created by Fabio Ludovici <fabio.ludovici AT yahoo DOT 
it>.
+
+
-- 
1.6.3.3

-- 
Fabio Ludovici

