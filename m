From: James Morris <jmorris@intercode.com.au>
Subject: Re: [PATCH][IPV6] keeping dst refcnt correctly with using xfrm
Date: Mon, 9 Jun 2003 01:47:52 +1000 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Mutt.LNX.4.44.0306090145030.3907-100000@excalibur.intercode.com.au>
References: <20030606144925.29ad2a9f.kazunori@miyazawa.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: davem@redhat.com, <kuznet@ms2.inr.ac.ru>, <usagi@linux-ipv6.org>,
   <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Kazunori Miyazawa <kazunori@miyazawa.org>
In-Reply-To: <20030606144925.29ad2a9f.kazunori@miyazawa.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 6 Jun 2003, Kazunori Miyazawa wrote:

> In output functions, dst is changed by xfrm_lookup if there is 
> any matching policy. Therefore original dst which is held before
> calling xfrm_lookup will be never released.
> When xfrm_lookup scceeds and dst is changed, original dst should
> be release.

It is released in xfrm_lookup():

        *dst_p = dst;
        ip_rt_put(rt);
        xfrm_pol_put(policy);
        return 0;


- James
-- 
James Morris
<jmorris@intercode.com.au>
