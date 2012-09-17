From: Rick Jones <rick.jones2@hp.com>
Subject: Re: NIC emulation with built-in rate limiting?
Date: Mon, 17 Sep 2012 14:48:29 -0700
Message-ID: <50579AAD.6030004@hp.com>
References: <504F7DCB.3050401@hp.com> <504F8B96.7070302@aesgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kvm@vger.kernel.org,
	Lee Schermerhorn <Lee.Schermerhorn@hp.com>,
	Brian Haley <Brian.Haley@hp.com>
To: Gregory Carter <gcarter@aesgi.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <504F8B96.7070302@aesgi.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

So, while the question includes the "stability" of how things get 
plumbed for a VM and whether moving some of that into the NIC emulation 
might help :)  I've gone ahead and re-run the experiment with bare-iron. 
  This time just for kicks I used 50 Mbit/s throttle inbound and 
outbound.  The results can be seen in:

ftp://ftp.netperf.org/50_mbits.tgz

Since this is now bare-iron, inbound is ingress and outbound is egress. 
  That is reversed from what it would be for a VM situation where VM 
outbound traverses the ingress filter and VM inbound traverses the 
egress qdisc.

Both systems were running Ubuntu 12.04.01 3.2.0-26 kernels, there was 
plenty of CPU horsepower (2x E5-2680s in this case) and the network 
between them was 10GbE using their 530FLB LOMs (BCM 57810S) connected 
via a ProCurve 6120 10GbE switch.  That simply happened to be the most 
convenient bare-iron hardware I had on hand as one of the cobbler's 
children.  There was no X running on the systems, the only thing of note 
running on them was netperf.

So, is the comparative instability between inbound and outbound 
fundamentally inherent in using ingress policing, or more a matter of 
"Silly Rick, you should be using <these settings> instead?"

If the former, is it then worthwhile to try to have NIC emulation only 
pull from the VM at the emulated rate, to keep the queues in the VM 
where it can react to them more directly?  And are there any NIC 
emulations doing that already (as virtio does not seem to at present)?

happy benchmarking,

rick jones
