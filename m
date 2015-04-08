From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: [PATCH 01/14] parport: return value of attach and
 parport_register_driver
Date: Wed, 8 Apr 2015 14:44:37 +0300
Message-ID: <20150408114437.GI10964@mwanda>
References: <1428492040-5581-1-git-send-email-sudipm.mukherjee@gmail.com>
 <1428492040-5581-2-git-send-email-sudipm.mukherjee@gmail.com>
 <20150408113832.GH10964@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, Rodolfo Giometti <giometti@enneenne.com>,
 linux-scsi@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>,
 Wolfram Sang <wsa@the-dreams.de>, Takashi Iwai <tiwai@suse.de>,
 Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-spi@vger.kernel.org,
 linux-kernel@vger.kernel.org,
 "James E.J. Bottomley" <JBottomley@parallels.com>,
 Jaroslav Kysela <perex@perex.cz>, Mark Brown <broonie@kernel.org>,
 linux-i2c@vger.kernel.org, Willy Tarreau <willy@meta-x.org>,
 alsa-devel@alsa-project.org, netdev@vger.kernel.org,
 Jean Delvare <jdelvare@suse.de>
To: Sudip Mukherjee <sudipm.mukherjee@gmail.com>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
Content-Disposition: inline
In-Reply-To: <20150408113832.GH10964@mwanda>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

On Wed, Apr 08, 2015 at 02:38:32PM +0300, Dan Carpenter wrote:
> 1) We can't apply this patch on its own so this way of breaking up the
> patches doesn't work.
> 

The right thing is to do add an attach_ret().

static int do_attach(drv)
{
	if (drv->attach_ret)
		return drv->attach_ret();
	drv->attach();
	return 0;
}

Then we convert one driver to use the new function pointer and see if
it simplifies the code.  If so we can transition the others as well.  If
not then we give up.

regards,
dan carpenter
