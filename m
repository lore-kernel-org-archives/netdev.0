From: Rick Jones <rick.jones2@hp.com>
Subject: Re: skbuff truesize incorrect.
Date: Fri, 23 May 2014 08:44:01 -0700
Message-ID: <537F6CC1.2000503@hp.com>
References: <537E4AFD.20304@mentor.com> <1400792295.5367.174.camel@edumazet-glaptop2.roam.corp.google.com> <1400792601.5367.176.camel@edumazet-glaptop2.roam.corp.google.com> <20140522.171033.1040508444998374401.davem@davemloft.net> <87ppj5vupf.fsf@nemi.mork.no> <537F0DCA.6030901@mentor.com> <87vbsw4z5x.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, eric.dumazet@gmail.com,
	linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, kamal@canonical.com, edumazet@google.com,
	mszeredi@suse.cz, fw@strlen.de
To: =?UTF-8?B?QmrDuHJuIE1vcms=?= <bjorn@mork.no>,
	Jim Baxter <jim_baxter@mentor.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87vbsw4z5x.fsf@nemi.mork.no>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 05/23/2014 02:33 AM, Bj=C3=B8rn Mork wrote:
> Jim Baxter <jim_baxter@mentor.com> writes:
>
>>> I'll create and test a patch for the cdc_ncm host driver unless som=
eone
>>> else wants to do that. I haven't really played with the gadget driv=
er
>>> before, so I'd prefer if someone knowing it (Jim maybe?) could take=
 care
>>> of it.  If not, then I can always make an attempt using dummy_hcd t=
o
>>> test it.
>> I can create a patch for the host driver, I will issue the gadget pa=
tch
>> first to resolve any issues, the fix would be similar.
>
> Well, I couldn't help myself.  I just had to test it.  The attached
> patch works for me, briefly tested with an Ericsson H5321gw NCM devic=
e.
> I have no ideas about the performance impact as that modem is limited=
 to
> 21 Mbps HSDPA.

If you are measuring performance with the likes of netperf, you should=20
be able to get an idea of the performance effect from the change in=20
service demand (CPU consumed per unit of work) even if the maximum=20
throughput remains capped.

You can run a netperf TCP_STREAM test along the lines of:

netperf -H <otherguy> -c -C -t TCP_STREAM

and also

netperf -H <otherguy> -c -C -t TCP_RR

=46or extra added credit you can consider either multiple runs and=20
post-processing, or adding a -i 30,3 to the command line to tell netper=
f=20
to run at least three iterations, no more than thirty and it will try t=
o=20
achieve a 99% confidence that the reported means for throughput, local=20
and remote CPU utilization are within +/- 2.5% of the actual mean.  You=
=20
can narrow or widen that with a -I 99,<width>.  A width of 5% is what=20
gives the +/- 2.5% (and/or demonstrates my lack of accurate statistics=20
knowledge :) )

happy benchmarking,

rick jones
