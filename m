From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] ip_vti: Fix 'ip tunnel add' with 'key' parameters
Date: Wed, 11 Jun 2014 00:31:17 -0700 (PDT)
Message-ID: <20140611.003117.1126488754203319453.davem@davemloft.net>
References: <20140608020625.87ea7e0baeb32c77f2028742@qrator.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, steffen.klassert@secunet.com,
	herbert@gondor.apana.org.au, sergei.shtylyov@cogentembedded.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: ixaphire@qrator.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140608020625.87ea7e0baeb32c77f2028742@qrator.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dmitry Popov <ixaphire@qrator.net>
Date: Sun, 8 Jun 2014 02:06:25 +0400

> ip tunnel add remote 10.2.2.1 local 10.2.2.2 mode vti ikey 1 okey 2
> translates to p->iflags = VTI_ISVTI|GRE_KEY and p->i_key = 1, but GRE_KEY !=
> TUNNEL_KEY, so ip_tunnel_ioctl would set i_key to 0 (same story with o_key) 
> making us unable to create vti tunnels with [io]key via ip tunnel.
> 
> We cannot simply translate GRE_KEY to TUNNEL_KEY (as GRE module does) because 
> vti_tunnels with same local/remote addresses but different ikeys will be treated
> as different then. So, imo the best option here is to move p->i_flags & *_KEY 
> check for vti tunnels from ip_tunnel.c to ip_vti.c and to think about [io]_mark
> field for ip_tunnel_parm in the future.
> 
> Signed-off-by: Dmitry Popov <ixaphire@qrator.net>

Applied, thanks.
