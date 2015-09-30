From: "Charles (Chas) Williams" <3chas3@gmail.com>
Subject: Re: [PATCH 07/12] atm: hide 'struct zatm_t_hist'
Date: Wed, 30 Sep 2015 11:24:35 -0400
Message-ID: <1443626675.3494.41.camel@gmail.com>
References: <1443612402-3000775-1-git-send-email-arnd@arndb.de>
	 <1443612402-3000775-8-git-send-email-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, y2038@lists.linaro.org,
	linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	linux-atm-general@lists.sourceforge.net
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1443612402-3000775-8-git-send-email-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2015-09-30 at 13:26 +0200, Arnd Bergmann wrote:
> The zatm_t_hist structure is not used anywhere in the kernel, but is
> exported to user space. As we are trying to eliminate uses of time_t
> in the kernel for y2038 compatibility, the current definition triggers
> checking tools because it contains 'struct timeval'.
> 
> We can work around this by adding '#ifdef __KERNEL__'. I could not find
> out what the structure is actually used for, so this is the safe choice
> in case there is some user space tool that relies on the definition.
> 
> If we are sure that nothing in user space relies on the structure, we
> can instead remove the definition completely.

It was used by the ZATM_GETHIST ioctl which is long since gone in the
kernel driver.  You can just remove this.
