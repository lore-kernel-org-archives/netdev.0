From: Kazunori Miyazawa <kazunori@miyazawa.org>
Subject: Re: [PATCH][IPV6] keeping dst refcnt correctly with using xfrm
Date: Mon, 9 Jun 2003 09:49:18 +0900
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030609094918.3c26d296.kazunori@miyazawa.org>
References: <20030606144925.29ad2a9f.kazunori@miyazawa.org>
	<Mutt.LNX.4.44.0306090145030.3907-100000@excalibur.intercode.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com, kuznet@ms2.inr.ac.ru, usagi@linux-ipv6.org,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: James Morris <jmorris@intercode.com.au>
In-Reply-To: <Mutt.LNX.4.44.0306090145030.3907-100000@excalibur.intercode.com.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 9 Jun 2003 01:47:52 +1000 (EST)
James Morris <jmorris@intercode.com.au> wrote:

> On Fri, 6 Jun 2003, Kazunori Miyazawa wrote:
> 
> > In output functions, dst is changed by xfrm_lookup if there is 
> > any matching policy. Therefore original dst which is held before
> > calling xfrm_lookup will be never released.
> > When xfrm_lookup scceeds and dst is changed, original dst should
> > be release.
> 
> It is released in xfrm_lookup():
> 
>         *dst_p = dst;
>         ip_rt_put(rt);
>         xfrm_pol_put(policy);
>         return 0;
> 
> 

I overlooked it. Thank you. 

--Kazunori Miyazawa (Yokogawa Electric Corporation)
