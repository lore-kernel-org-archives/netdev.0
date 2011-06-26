From: Martin Jackson <mjackson220.list@gmail.com>
Subject: Re: ppp_deflate + kmalloc
Date: Sun, 26 Jun 2011 23:17:54 +0200
Message-ID: <BANLkTinMNb65nyo+Y8xhpTP2RC6x06ZJqQ@mail.gmail.com>
References: <BANLkTi=+2dqr1LPwG8MHpcYOyzJH57iavw@mail.gmail.com>
	<4E049900.4080402@workingcode.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: paulus@samba.org, linux-ppp@vger.kernel.org, netdev@vger.kernel.org
To: James Carlson <carlsonj@workingcode.com>
Return-path: <linux-ppp-owner@vger.kernel.org>
In-Reply-To: <4E049900.4080402@workingcode.com>
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jun 24, 2011 at 4:02 PM, James Carlson <carlsonj@workingcode.co=
m> wrote:
> Martin Jackson wrote:
>> In our android froyo-based system (omap3 hardware), we are getting t=
he
>> following problem where the ppp driver cannot kmalloc enough memory
>> for the decomp buffer in the ppp driver.
>>
>> Trying to make a 4th-order kmalloc (I think that amounts to 64kB)
>> seems ambitious. I do not understand why vmalloc is not being used
>> here, like it is for the compression buffer. Is using vmalloc here a=
n
>> acceptable solution?
>
> The code here shouldn't need contiguous pages, so vmalloc (even if
> "slower") shouldn't be a problem.
>
> But a higher-level question might be why you're bothering with RFC 19=
79
> Deflate compression at all on this platform. =A0I'd expect that you'r=
e
> most likely going to end up talking to commercially-produced PPP serv=
ers
> (possibly 3GPP or similar) at the other end, and very, very few of th=
em
> offer data compression with either RFC 1977 (BSD Compression) or RFC
> 1979. =A0("Very, very few" is probably being generous ...)
>
> If it's always going to be negotiated away in practice, and if you're
> having trouble with memory constraints, why not just ditch the baggag=
e?
>
> --
> James Carlson =A0 =A0 =A0 =A0 42.703N 71.076W =A0 =A0 =A0 =A0 <carlso=
nj@workingcode.com>
>

Thanks for the advice. Hopefully we can indeed remove these obscure
PPP options from our configuration - I'll look into that.

However, the point still stands that a 4th order kmalloc is likely to
fail (even our "embedded" device has 256MB RAM and slub allocator,
after all), and the page allocation code regards anything above order
3 as unrealistic and doesn't invoke the OOM to try to satisfy it, so
my view remains that this should be changed to vmalloc.

Best regards,

Martin Jackson
