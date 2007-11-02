From: Rick Jones <rick.jones2@hp.com>
Subject: Re: bizarre network timing problem
Date: Fri, 02 Nov 2007 15:58:24 -0700
Message-ID: <472BAB90.8020306@hp.com>
References: <20071017205127.GA21334@codeblau.de> <47167BDE.4000103@redhat.com>	<20071017220019.GA22765@codeblau.de> <471689BF.2040909@hp.com>	<20071018094230.GA2978@codeblau.de> <4717964A.8080100@hp.com>	<20071102221146.GA4354@codeblau.de> <472BA5BC.6000901@hp.com> <20071102223856.GA5121@codeblau.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Chuck Ebbert <cebbert@redhat.com>, linux-kernel@vger.kernel.org,
	Netdev <netdev@vger.kernel.org>
To: Felix von Leitner <felix-linuxkernel@fefe.de>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758028AbXKBW6j@vger.kernel.org>
In-Reply-To: <20071102223856.GA5121@codeblau.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Felix von Leitner wrote:
> Thus spake Rick Jones (rick.jones2@hp.com):
> 
>>>Oh I'm pretty sure it's not my application, because my application performs
>>>well over ethernet, which is after all its purpose.  Also I see the
>>>write, the TCP uncork, then a pause, and then the packet leaving.
>>
>>Well, a wise old engineer tried to teach me that the proper spelling is 
>>ass-u-me :) so just for grins, you might try the TCP_RR test anyway :)  And 
>>even if your application is correct (although I wonder why the receiver 
>>isn't sucking data-out very quickly...) if you can reproduce the problem 
>>with netperf it will be easier for others to do so.
> 
> 
> My application is only the server, the receiver is smbget from Samba, so
> I don't feel responsible for it :-)

Might want to strace it anyway... no good deed (such as reporting a potential 
issue) goes unpunished :)

> Still, when run over Ethernet, it works fine without waiting for
> timeouts to expire.

Past performance is no guarantee of current correctness :)  And over an 
Ethernet, there will be a very different set of both timings and TCP segment 
sizes compared to loopback.

My guess is that you will find setting the lo mtu to 1500 a very interesting 
experiment.

> 
> To reproduce this:
> 
>   - smbget is from samba, you probably already have this
>   - gatling (my server) can be gotten from
>     cvs -d :pserver:cvs@cvs.fefe.de:/cvs -z9 co dietlibc libowfat gatling
> 
> dietlibc is not strictly needed, but it's my environment.
> First built dietlibc, then libowfat, then gatling.
> 
> Felix
