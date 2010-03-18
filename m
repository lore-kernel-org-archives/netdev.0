From: Darren Jenkins <darrenrjenkins@gmail.com>
Subject: Re: [PATCH] drivers/net/wimax/i2400m/fw.c fix possible double free
Date: Thu, 18 Mar 2010 19:46:48 +1100
Message-ID: <1268902008.10536.41.camel@ICE-BOX>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "Kao, Cindy H" <cindy.h.kao@intel.com>,
	"wimax@linuxwimax.org" <wimax@linuxwimax.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"kernel-janitors@vger.kernel.org" <kernel-janitors@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	linux-wimax <linux-wimax@intel.com>, David Miller <davem@davemloft.net>
To: Inaky Perez-Gonzalez <inaky.perez-gonzalez@intel.com>
Return-path: <wimax-bounces@linuxwimax.org>
List-Unsubscribe: <http://lists.linuxwimax.org/options/wimax>,
	<mailto:wimax-request@linuxwimax.org?subject=unsubscribe>
List-Archive: <http://lists.linuxwimax.org/pipermail/wimax>
List-Post: <mailto:wimax@linuxwimax.org>
List-Help: <mailto:wimax-request@linuxwimax.org?subject=help>
List-Subscribe: <http://lists.linuxwimax.org/listinfo/wimax>,
	<mailto:wimax-request@linuxwimax.org?subject=subscribe>
Sender: wimax-bounces@linuxwimax.org
Errors-To: wimax-bounces@linuxwimax.org
List-Id: netdev.vger.kernel.org


On Thu, Mar 18, 2010 at 9:10 AM, Inaky Perez-Gonzalez
<inaky.perez-gonzalez@intel.com> wrote:

> If krealloc() fails to aallocate a new pointer, the old block is
> unmodified, so by doing this you are leaking a buffer allocation.

It seems you are right.
So now understanding correctly how krealloc() works I can see that the
double kfree() can only actually happen if the el_size parameter to
i2400m_zrealloc_2x() is zero, and it isn't at the two call sites.

So this was a false positive and I am sorry for the noise.

Darren J.
