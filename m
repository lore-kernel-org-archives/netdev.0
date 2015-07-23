From: Dexuan Cui <decui@microsoft.com>
Subject: RE: [PATCH V3 3/7] Drivers: hv: vmbus: add APIs to send/recv hvsock
 packet and get the r/w-ability
Date: Thu, 23 Jul 2015 03:05:16 +0000
Message-ID: <75f1792c788e418eaddc0d6b7e3381de@SIXPR30MB031.064d.mgd.msft.net>
References: <1437476293-6837-1-git-send-email-decui@microsoft.com>
 <87zj2pk3jf.fsf@vitty.brq.redhat.com>
 <4538264677374d43961c2d709afb1dd3@SIXPR30MB031.064d.mgd.msft.net>
 <20150722103546.GO5371@mwanda>
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
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <20150722103546.GO5371@mwanda>
Content-Language: en-US
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

> From: Dan Carpenter
> Sent: Wednesday, July 22, 2015 18:36
> To: Dexuan Cui
> On Wed, Jul 22, 2015 at 10:09:10AM +0000, Dexuan Cui wrote:
> > > I'd suggest you do something like
> > >
> > >     if (ret == -EAGIAIN)
> > >         return 0;
> > >     else if (ret)
> > >         return ret;
> > >
> > > to make it future-proof (e.g. when a new error is returned by
> > > hv_ringbuffer_peek). And a comment would also be useful as it is unclear
> > > why we silence errors here.
> > Hi Vitaly,
> > Thanks!
> > I think I made a mistake here:
> > the "if (ret != 0) return 0;" should be changed
> > to   "if (ret != 0) return ret;"
Usually 0 means success to me, so 
to me, "ret != 0" reads like "ret is not successful" and seems natural. 

The kind of usage is not rare in the kernel code:

decui@lin:~/linux-next$ grep 'if (ret != 0)' kernel/ include/ ipc/  -r  | wc -l
28
decui@lin:~/linux-next$ grep 'if (ret != 0)' drivers/   -r  | wc -l
1031
 
> The double negative really doesn't not make the code more complicated.
> I like using a quadruple negative instead.
> 
> 	if (ret != 0 != 0)
> 		return ret;
> dan carpenter
Hi Dan, I read this as a humor.  :-)

I'll take the suggestion and remember to use this in V4 and in future:
 
if (ret)
	return ret;

Thanks!

-- Dexuan
