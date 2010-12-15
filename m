From: Ted Ts'o <tytso-3s7WtUTddSA@public.gmane.org>
Subject: Re: [PATCH v3 21/22] netoops: Add user-programmable boot_id
Date: Tue, 14 Dec 2010 21:16:51 -0500
Message-ID: <20101215021651.GA9463@thunk.org>
References: <20101214212846.17022.64836.stgit@mike.mtv.corp.google.com>
 <20101214213048.17022.58746.stgit@mike.mtv.corp.google.com>
 <1292362957.3446.851.camel@calx>
 <AANLkTi=Q+LaS7yaU_4ThkhMUM-q8S3JTuwMWqAikQPgH@mail.gmail.com>
 <1292364378.3446.854.camel@calx>
 <AANLkTineeFcSNx09P=2SZGcBHeq5p_LQ54nU=uGVv_Ck@mail.gmail.com>
 <1292366864.3446.875.camel@calx>
 <AANLkTinugLaeuHjOAY6s=Vhwo-VOYr9dz7OE7GZFH+xK@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Matt Mackall <mpm-VDJrAJ4Gl5ZBDgjK7y7TUQ@public.gmane.org>, simon.kagstrom-vI6UBbBVNY+JA8cjQkG2/g@public.gmane.org,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, adurbin-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, chavey-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org,
	Greg KH <greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	=?iso-8859-1?Q?Am=E9rico?= Wang <xiyou.wangcong-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Mike Waychison <mikew-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <AANLkTinugLaeuHjOAY6s=Vhwo-VOYr9dz7OE7GZFH+xK-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Dec 14, 2010 at 03:19:50PM -0800, Mike Waychison wrote:
> 
> I'm not sure there is a _good_ way to support this, is there?  I just
> read through RFC 4122 and UUIDs seem to be pretty well structured;
> it's probably not such a great idea to allow folks to override
> portions of it.  Like I mentioned in my last email though, I'm okay
> pushing this boot sequence ID down into the user blob which acts like
> a place for "vendor extensions" if there isn't a good place for it in
> the kernel.

If you really wanted to do it I could imagine using a time-based UUID
(see RFC 4122, section 4.2), where the boot sequence number could be
mapped into the 14-bit clock sequence, and using the time read from
the hardware counter and the ethernet MAC address from... umm the
"first" ethernet port (depending on how you define that) to form a
UUID.  I'm not convinced it's really worth it, though, unless someone
really wants a good per-boot session UUID generated some other way
than a random number generator that may not be all that adequately
seed at the time when you first sample the boot session UUID.

I suspect pushing the boot sequence ID into its own special field with
the semantics that you want is probably the better way to go.

     	     	    	      	  	- Ted
