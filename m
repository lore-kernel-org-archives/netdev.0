From: Joe Perches <joe@perches.com>
Subject: Re: [ath9k-devel] [PATCH net-next 1/2] wireless: Remove casts of
 void *
Date: Tue, 14 Jun 2011 09:43:51 -0700
Message-ID: <1308069831.21026.9.camel@Joe-Laptop>
References: <cover.1308024069.git.joe@perches.com>
	 <337c22b774ff7f007b90b266b25c9a33ff555c48.1308024069.git.joe@perches.com>
	 <4DF78CEC.70409@gnu.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Intel Linux Wireless <ilw@linux.intel.com>,
	linux-kernel@vger.kernel.org, linux-wireless@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>,
	Jouni Malinen <jmalinen@atheros.com>,
	Senthil Balasubramanian <senthilkumar@atheros.com>,
	ath9k-devel@lists.ath9k.org, Wey-Yi Guy <wey-yi.w.guy@intel.com>,
	Vasanthakumar Thiagarajan <vasanth@atheros.com>,
	Christian Lamparter <chunkeey@googlemail.com>,
	Stanislaw Gruszka <sgruszka@redhat.com>
To: Pavel Roskin <proski@gnu.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4DF78CEC.70409@gnu.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2011-06-14 at 12:31 -0400, Pavel Roskin wrote:
> On 06/14/2011 12:02 AM, Joe Perches wrote:
> >   		/* Get the message ID */
> > -		msg_id = (__be16 *) ((void *) htc_hdr +
> > -				     sizeof(struct htc_frame_hdr));
> > +		msg_id = (void *)htc_hdr + sizeof(struct htc_frame_hdr);
> I would never do stuff like this without verifying by sparse that no 
> warnings are introduced.

I did that.  I believe there are no new warnings.

> Sparse warnings should be avoided to keep sparse checks useful. 
> Otherwise, important warnings would drown in the noise.

$ make allyesconfig
$ git log -1 --pretty=oneline drivers/net/wireless/ath/ath9k/htc_hst.c
337c22b774ff7f007b90b266b25c9a33ff555c48 wireless: Remove casts of void *
$ make C=2 drivers/net/wireless/ath/ath9k/htc_hst.o
make[1]: Nothing to be done for `all'.
  CHK     include/linux/version.h
  CHK     include/generated/utsrelease.h
  CALL    scripts/checksyscalls.sh
  CHECK   scripts/mod/empty.c
  CHECK   drivers/net/wireless/ath/ath9k/htc_hst.c
  CC      drivers/net/wireless/ath/ath9k/htc_hst.o
$
