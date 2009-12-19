From: Stefano Salsano <stefano.salsano@uniroma2.it>
Subject: Re: [PATCH] netem/iproute2 solving correlated loss issues [2/5]
Date: Sat, 19 Dec 2009 10:48:29 +0100
Message-ID: <4B2CA16D.4090801@uniroma2.it>
References: <4B2B5A26.8050400@uniroma2.it>	<4B2B6676.301@yahoo.it>	<20091218093605.76903fe5@nehalam> <20091218.200158.112585402.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, fabio.ludovici@yahoo.it,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.uniroma2.it ([160.80.6.16]:57250 "EHLO smtp.uniroma2.it"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751095AbZLSJsd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 19 Dec 2009 04:48:33 -0500
In-Reply-To: <20091218.200158.112585402.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> I would like some kind of commit message which at least
> explains what in the world this stuff is, how it works,
> why we want it etc.
> 

you're right we will put this information in the commit messages, some 
hints hereafter:

starting from the consideration that the model for generating correlated 
loss is broken in current netem (as for example described in
https://lists.linux-foundation.org/pipermail/netem/2007-September/001156.html)
we have implemented a more general loss model

the patch allows to generate loss patterns according to a determinist 
pattern that can be given as input:

tc qdisc add/change dev eth0 root netem loss_pattern filename

or according to different loss models including the ones commonly used 
in the literature (bernoulli, gilbert, gilbert-elliot...)

tc qdisc add/change dev eth0 root netem loss_bern       p
tc qdisc add/change dev eth0 root netem loss_gilb       p r [1-h]
tc qdisc add/change dev eth0 root netem loss_gilbell    p r [1-h [1-k]]
tc qdisc add/change dev eth0 root netem loss_GI         ploss 
[burst_length [density [pisol [good_burst_length]]]]
tc qdisc add/change dev eth0 root netem loss_GI_tran    p13 p31 [p32 p23 
[p14]]
tc qdisc add/change dev eth0 root netem loss_gilb_4s    p r [1-h]
tc qdisc add/change dev eth0 root netem loss_gilbell_4s p r [1-h [1-k]]

(full explanation is reported in 
http://netgroup.uniroma2.it/twiki/bin/view.cgi/Main/NetEm2)


-- 
*******************************************************************
Stefano Salsano
Dipartimento Ingegneria Elettronica
Universita' di Roma "Tor Vergata"
Via del Politecnico, 1 - 00133 Roma - ITALY

http://netgroup.uniroma2.it/Stefano_Salsano/

E-mail  : stefano.salsano@uniroma2.it
Cell.   : +39 320 4307310
Office  : (Tel.) +39 06 72597770  (Fax.) +39 06 72597435
*******************************************************************
