From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 2/3] NET: Generic rate estimator
Date: Mon, 4 Oct 2004 17:29:15 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041004152915.GC15898@postel.suug.ch>
References: <20041003213124.GG14344@postel.suug.ch> <20041003213954.GI14344@postel.suug.ch> <20041003161436.50293f9a.davem@davemloft.net> <20041003233647.GN14344@postel.suug.ch> <1096852582.1046.378.camel@jzny.localdomain> <20041004125300.GA15898@postel.suug.ch> <1096896256.1072.4.camel@jzny.localdomain> <20041004141532.GB15898@postel.suug.ch> <1096901984.1073.9.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1096901984.1073.9.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* jamal <1096901984.1073.9.camel@jzny.localdomain> 2004-10-04 10:59
> is that bad to let those have a slight different innacurate value?

I don't see this as a problem, I think the timers will be more
inacurate anyway.

> BTW wasnt there a jiffies2ms converter somewhere that we could use?
> I thought i saw something posted of that nature recently.

#define PSCHED_US2JIFFIE(delay)
#define PSCHED_JIFFIE2US(delay)

but we don't have half a jiffie ;) The only way to make it accurate in
the case of 122 and 50 would be to set timer_expires based on a flip-flop
adding HZ/4 and (HZ/4)+1 repeaditly and this only works if HZ%2==0.

I would be fine using PSCHED_ because the user can decide accuracy
over performance and vice versa. It would make the code dependant on
sch_api.c though.

> There should really be no difference between the two;-> you realize /4
> is merely <<2 ?

Oh yes there is: HZ=50, idx=2

(HZ/4)<<idx:
octave:8> 50/4
ans = 12.500
octave:9> dec2bin(12)
ans = 1100
octave:10> bin2dec('110000')
ans = 48

(HZ<<idx)/4:
octave:11> dec2bin(50)
ans = 110010
octave:12> bin2dec('11001000')
ans = 200
octave:13> 200/4
ans = 50

It avoids carrying on the inaccuracy, of course this only works because
(2*HZ)%4==0 is true for all existing HZ values. Or do I misundstand the
compiler and it's all in floating points?
