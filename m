From: "Steinar H. Gunderson" <sgunderson@bigfoot.com>
Subject: Re: NULL pointer dereference when loading the gre module (3.10.0-rc4)
Date: Fri, 7 Jun 2013 10:54:21 +0200
Message-ID: <20130607085421.GF15083@uio.no>
References: <20130606221656.GA11475@uio.no>
 <20130607030648.GA28618@home.goodmis.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: linux-kernel@vger.kernel.org, davem@davemloft.net,
	netdev@vger.kernel.org, Rusty Russell <rusty@rustcorp.com.au>
To: Steven Rostedt <rostedt@goodmis.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20130607030648.GA28618@home.goodmis.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jun 06, 2013 at 11:06:48PM -0400, Steven Rostedt wrote:
> Note the faulting address is 0xffffffffa0e52001, which is around the
> above address, be interesting to know what was at that location.

Doh, I looked at the wrong place in kallsyms:

ffffffffa0e52000 u ip_tunnel_init_net   [ip_gre]
ffffffffa0e55000 t gre_err      [gre]
ffffffffa0e5503d t gre_gso_send_check   [gre]
ffffffffa0e55053 t gre_rcv      [gre]

So it's really ip_tunnel_init_net+1.

/* Steinar */
-- 
Homepage: http://www.sesse.net/
