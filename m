From: Mike Waychison <mikew-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH v3 21/22] netoops: Add user-programmable boot_id
Date: Tue, 14 Dec 2010 15:19:50 -0800
Message-ID: <AANLkTinugLaeuHjOAY6s=Vhwo-VOYr9dz7OE7GZFH+xK@mail.gmail.com>
References: <20101214212846.17022.64836.stgit@mike.mtv.corp.google.com>
 <20101214213048.17022.58746.stgit@mike.mtv.corp.google.com>
 <1292362957.3446.851.camel@calx> <AANLkTi=Q+LaS7yaU_4ThkhMUM-q8S3JTuwMWqAikQPgH@mail.gmail.com>
 <1292364378.3446.854.camel@calx> <AANLkTineeFcSNx09P=2SZGcBHeq5p_LQ54nU=uGVv_Ck@mail.gmail.com>
 <1292366864.3446.875.camel@calx>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: simon.kagstrom-vI6UBbBVNY+JA8cjQkG2/g@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, adurbin-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, chavey-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org,
	Greg KH <greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	=?ISO-8859-1?Q?Am=E9rico_Wang?= <xiyou.wangcong-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Matt Mackall <mpm-VDJrAJ4Gl5ZBDgjK7y7TUQ@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1292366864.3446.875.camel@calx>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Dec 14, 2010 at 2:47 PM, Matt Mackall <mpm-VDJrAJ4Gl5ZBDgjK7y7TUQ@public.gmane.org> wrote:
> On Tue, 2010-12-14 at 14:33 -0800, Mike Waychison wrote:
>> On Tue, Dec 14, 2010 at 2:06 PM, Matt Mackall <mpm-VDJrAJ4Gl5ZBDgjK7y7TUQ@public.gmane.org> wrot=
e:
>> > What happens if you oops before userspace is available?
>> >
>>
>> Either one of two general cases:
>> =A0 - The crash is a one-off and the machine comes back. =A0The boot
>> number sequence will see a hole in it, which is a clue that somethin=
g
>> bad happened.
>> =A0 - The machine is in a crash loop. =A0This has the same failure m=
ode
>> for us as if the machine never made it onto the network due to
>> whatever reason: bad cables, bad firmware, bad ram, ...
>>
>> In both cases, we can detect that something is wrong and handle it.
>> Note that our firmware is responsible for incrementing the boot
>> sequence at bootup, which is why the above works. =A0 In general tho=
ugh,
>> our machines do make it up to userland -- staying alive once booted =
is
>> the hard part ;)
>
> Interesting. Is this Google-specific firmware magic?

Ya, this is a Google-ism.  I'd be surprised if there weren't other
platforms that had the same thing though (though I don't know of
anything standard on x86).

> I'd probably accept
> a hook in random.c to fold a number into the UUID, which would unify
> things.

I'm not sure there is a _good_ way to support this, is there?  I just
read through RFC 4122 and UUIDs seem to be pretty well structured;
it's probably not such a great idea to allow folks to override
portions of it.  Like I mentioned in my last email though, I'm okay
pushing this boot sequence ID down into the user blob which acts like
a place for "vendor extensions" if there isn't a good place for it in
the kernel.
