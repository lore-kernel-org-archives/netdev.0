From: KY Srinivasan <kys@microsoft.com>
Subject: RE: [PATCH V3 0/6] Drivers: net: hyperv: Enable various offloads
Date: Tue, 11 Mar 2014 00:42:35 +0000
Message-ID: <8a794a772a8044d9bd3a22197da57945@BY2PR03MB299.namprd03.prod.outlook.com>
References: <1394335362-11126-1-git-send-email-kys@microsoft.com>
 <20140310.155557.1576514754598895473.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "olaf@aepfle.de" <olaf@aepfle.de>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 "jasowang@redhat.com" <jasowang@redhat.com>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 "apw@canonical.com" <apw@canonical.com>,
 "devel@linuxdriverproject.org" <devel@linuxdriverproject.org>
To: David Miller <davem@davemloft.net>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <20140310.155557.1576514754598895473.davem@davemloft.net>
Content-Language: en-US
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: driverdev-devel-bounces@linuxdriverproject.org
List-Id: netdev.vger.kernel.org



> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Tuesday, March 11, 2014 1:26 AM
> To: KY Srinivasan
> Cc: netdev@vger.kernel.org; linux-kernel@vger.kernel.org;
> devel@linuxdriverproject.org; olaf@aepfle.de; apw@canonical.com;
> jasowang@redhat.com
> Subject: Re: [PATCH V3 0/6] Drivers: net: hyperv: Enable various offloads
> 
> From: "K. Y. Srinivasan" <kys@microsoft.com>
> Date: Sat,  8 Mar 2014 19:22:42 -0800
> 
> > This patch set enables both checksum as well as segmentation offload.
> > As part of this effort I have enabled scatter gather I/O a well.
> >
> > In version 2 of these patches, I addressed comments from David Miller
> > and Dan Carpenter.
> >
> > In this version I have addressed the latest comments from David Miller.
> 
> Series applied, thanks.
> 
> I still think that fill_pg_buf() could be improved.
> 
> For example, it returns '1' if len is passed in as zero.  Maybe that can't
> happen, but if it does the page buffer array will be corrupted and the driver
> will process garbage.
> 
> It seems so much more straightforward to me if you simply incremented 'j' in
> the loop when an array entry is actually filled in.  Then just return 'j'.
> 
> 	int j; 
>  ...
> 		pb[j].pfn = page_to_pfn(page);
> 		pb[j].offset = offset;
> 		pb[j].len = bytes;
> 		j++;
>  ...
> 	return j;
> 
> 
> Then 'j' is unambiguously the number of pb array entries which were filled in,
> no matter what.
Thanks David. As you suggest, I will send a patch to make this cleaner.

Regards,

K. Y
