From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: [PATCH V3 3/7] Drivers: hv: vmbus: add APIs to send/recv hvsock
 packet and get the r/w-ability
Date: Wed, 22 Jul 2015 13:35:46 +0300
Message-ID: <20150722103546.GO5371@mwanda>
References: <1437476293-6837-1-git-send-email-decui@microsoft.com>
 <87zj2pk3jf.fsf@vitty.brq.redhat.com>
 <4538264677374d43961c2d709afb1dd3@SIXPR30MB031.064d.mgd.msft.net>
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
In-Reply-To: <4538264677374d43961c2d709afb1dd3@SIXPR30MB031.064d.mgd.msft.net>
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

On Wed, Jul 22, 2015 at 10:09:10AM +0000, Dexuan Cui wrote:
> > I'd suggest you do something like
> > 
> >     if (ret == -EAGIAIN)
> >         return 0;
> >     else if (ret)
> >         return ret;
> > 
> > to make it future-proof (e.g. when a new error is returned by
> > hv_ringbuffer_peek). And a comment would also be useful as it is unclear
> > why we silence errors here.
> Hi Vitaly,
> Thanks! 
> I think I made a mistake here:
> the "if (ret != 0) return 0;" should be changed
> to   "if (ret != 0) return ret;"

The double negative really doesn't not make the code more complicated.
I like using a quadruple negative instead.

	if (ret != 0 != 0)
		return ret;

regards,
dan carpenter
