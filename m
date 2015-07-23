From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: [PATCH V3 3/7] Drivers: hv: vmbus: add APIs to send/recv hvsock
 packet and get the r/w-ability
Date: Thu, 23 Jul 2015 13:24:50 +0300
Message-ID: <20150723102449.GR5371@mwanda>
References: <1437476293-6837-1-git-send-email-decui@microsoft.com>
 <87zj2pk3jf.fsf@vitty.brq.redhat.com>
 <4538264677374d43961c2d709afb1dd3@SIXPR30MB031.064d.mgd.msft.net>
 <20150722103546.GO5371@mwanda>
 <75f1792c788e418eaddc0d6b7e3381de@SIXPR30MB031.064d.mgd.msft.net>
 <20150723101057.GQ5371@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "pebolle@tiscali.nl" <pebolle@tiscali.nl>,
 "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>,
 "jasowang@redhat.com" <jasowang@redhat.com>,
 "driverdev-devel@linuxdriverproject.org"
 <driverdev-devel@linuxdriverproject.org>, "olaf@aepfle.de" <olaf@aepfle.de>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 "stephen@networkplumber.org" <stephen@networkplumber.org>,
 "stefanha@redhat.com" <stefanha@redhat.com>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 "apw@canonical.com" <apw@canonical.com>,
 "davem@davemloft.net" <davem@davemloft.net>
To: Dexuan Cui <decui@microsoft.com>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
Content-Disposition: inline
In-Reply-To: <20150723101057.GQ5371@mwanda>
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

On Thu, Jul 23, 2015 at 01:10:57PM +0300, Dan Carpenter wrote:
> In this specific case, writing it as "if (ret != 0)" caused the bug.  If
> we had written it as "if (ret) return ret;" then there are no zeroes so
> wouldn't have been any temptation to return the zero instead of the ret.

I did a search to see if returning the zero instead of the ret was a
common mistake and it seems like it might be.  I did:

grep 'if (ret != 0)' drivers/   -r -A1 -n | grep "return 0;" | perl -ne 's/.c-(\d+)-/.c:$1/; print'

drivers/gpu/drm/nouveau/nouveau_display.c:111                   return 0;
drivers/regulator/wm8400-regulator.c:47         return 0;
drivers/platform/x86/dell-laptop.c:859          return 0;
drivers/media/dvb-frontends/dibx000_common.c:213                                return 0;
drivers/media/dvb-frontends/dibx000_common.c:217                                return 0;
drivers/media/dvb-frontends/dibx000_common.c:235                                return 0;
drivers/media/dvb-frontends/dibx000_common.c:239                                return 0;
drivers/hv/channel.c:898                return 0;
drivers/hv/channel.c:944                return 0;

A bunch of those look suspicious but I don't know the subsystems well
enough to be sure.  Can you check the last two?

regards,
dan carpenter
