From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V3 0/6] Drivers: net: hyperv: Enable various offloads
Date: Mon, 10 Mar 2014 15:55:57 -0400 (EDT)
Message-ID: <20140310.155557.1576514754598895473.davem@davemloft.net>
References: <1394335362-11126-1-git-send-email-kys@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: olaf@aepfle.de, netdev@vger.kernel.org, jasowang@redhat.com,
 linux-kernel@vger.kernel.org, apw@canonical.com, devel@linuxdriverproject.org
To: kys@microsoft.com
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1394335362-11126-1-git-send-email-kys@microsoft.com>
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

From: "K. Y. Srinivasan" <kys@microsoft.com>
Date: Sat,  8 Mar 2014 19:22:42 -0800

> This patch set enables both checksum as well as segmentation offload.
> As part of this effort I have enabled scatter gather I/O a well.
> 
> In version 2 of these patches, I addressed comments from David Miller and
> Dan Carpenter.
> 
> In this version I have addressed the latest comments from David Miller.

Series applied, thanks.

I still think that fill_pg_buf() could be improved.

For example, it returns '1' if len is passed in as zero.  Maybe that can't
happen, but if it does the page buffer array will be corrupted and the
driver will process garbage.

It seems so much more straightforward to me if you simply incremented
'j' in the loop when an array entry is actually filled in.  Then just
return 'j'.

	int j;
 ...
		pb[j].pfn = page_to_pfn(page);
		pb[j].offset = offset;
		pb[j].len = bytes;
		j++;
 ...
	return j;


Then 'j' is unambiguously the number of pb array entries which were
filled in, no matter what.
