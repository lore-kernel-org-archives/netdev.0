From: Willy Tarreau <w@1wt.eu>
Subject: Re: [PATCH] net: mvneta: properly disable HW PHY polling and ensure
 adjust_link() works
Date: Thu, 5 Sep 2013 07:12:23 +0200
Message-ID: <20130905051223.GB26000@1wt.eu>
References: <1378304478-21237-1-git-send-email-thomas.petazzoni@free-electrons.com>
 <20130904163245.GI20552@1wt.eu>
 <CACzLR4uDQK2bkcEJQXLe805EfSA8=eF+YH-FTYovHA0q+8Y9NA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
 Lior Amsalem <alior@marvell.com>,
 Jochen De Smet <jochen.armkernel@leahnim.org>,
 Simon Guinot <simon.guinot@sequanux.org>, Ryan Press <ryan@presslab.us>,
 netdev@vger.kernel.org, vdonnefort@lacie.com, stable@vger.kernel.org,
 Ezequiel Garcia <ezequiel.garcia@free-electrons.com>,
 =?iso-8859-1?Q?Ch=E9ny?= Yves-Gael <yves@cheny.fr>,
 Gregory Clement <gregory.clement@free-electrons.com>,
 Peter Sanford <psanford@nearbuy.io>, "David S. Miller" <davem@davemloft.net>,
 linux-arm-kernel@lists.infradead.org
To: Ethan Tuttle <ethan@ethantuttle.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
Content-Disposition: inline
In-Reply-To: <CACzLR4uDQK2bkcEJQXLe805EfSA8=eF+YH-FTYovHA0q+8Y9NA@mail.gmail.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

Hi,

On Wed, Sep 04, 2013 at 09:14:23PM -0700, Ethan Tuttle wrote:
> Just booted with the patch on my Mirabox.  Both interfaces work!
> Thank you Thomas.
> 
> One remaining issue is that the interface which uBoot didn't configure
> is still getting a random mac address:
> 
> mvneta d0070000.ethernet eth0: Using hardware mac address f0:ad:4e:01:dc:97
> mvneta d0074000.ethernet eth1: Using random mac address d2:35:dd:c8:99:48
> 
> This is on 3.11 plus Thomas' patch, which includes the previous fix to
> "read MAC address from hardware when available".  Perhaps that fix
> isn't working with the phylib?

No this is unrelated. The MAC isn't configured by the boot loader when
the NIC is not used. U-boot only passes it as a non-standard ATAG. I
have some patches to reinject the non-standard atags into the device
tree if you absolutely need this, but they're not suited for mainline
inclusion from what I understood last time I proposed them (they use
a marvell-specific atag header).

Regards,
Willy
