From: Logan Gunthorpe <logang@deltatee.com>
Subject: Re: [PATCH 09/22] dm-crypt: Make use of the new sg_map helper in 4
 call sites
Date: Fri, 14 Apr 2017 10:03:43 -0600
Message-ID: <302ae5ab-d515-5427-2e54-d58a9cdb8241@deltatee.com>
References: <1492121135-4437-1-git-send-email-logang@deltatee.com>
 <1492121135-4437-10-git-send-email-logang@deltatee.com>
 <20170414083921.GC25471@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Steve Wise <swise@opengridcomputing.com>, linux-nvme@lists.infradead.org,
 Stephen Bates <sbates@raithlin.com>, target-devel@vger.kernel.org,
 Sumit Semwal <sumit.semwal@linaro.org>, devel@driverdev.osuosl.org,
 rds-devel@oss.oracle.com, Sagi Grimberg <sagi@grimberg.me>,
 linux-scsi@vger.kernel.org, Matthew Wilcox <mawilcox@microsoft.com>,
 linux-rdma@vger.kernel.org, fcoe-devel@open-fcoe.org,
 Ross Zwisler <ross.zwisler@linux.intel.com>, open-iscsi@googlegroups.com,
 linux-media@vger.kernel.org, Ming Lin <ming.l@ssi.samsung.com>,
 intel-gfx@lists.freedesktop.org, sparmaintainer@unisys.com,
 linux-raid@vger.kernel.org, dri-devel@lists.freedesktop.org,
 Dan Williams <dan.j.williams@intel.com>, megaraidlinux.pdl@broadcom.com,
 Jens Axboe <axboe@kernel.dk>, linaro-mm-sig@lists.linaro.org,
 "Martin K. Petersen" <martin.petersen@oracle.com>,
 Greg Kroah-Hartman <gregkh@linuxfoundation.org
To: Christoph Hellwig <hch@lst.de>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <20170414083921.GC25471@lst.de>
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



On 14/04/17 02:39 AM, Christoph Hellwig wrote:
> On Thu, Apr 13, 2017 at 04:05:22PM -0600, Logan Gunthorpe wrote:
>> Very straightforward conversion to the new function in all four spots.
> 
> I think the right fix here is to switch dm-crypt to the ahash API
> that takes a scatterlist.

Hmm, well I'm not sure I understand the code enough to make that
conversion. But I was looking at it. One tricky bit seems to be that
crypt_iv_lmk_one adds a seed, skips the first 16 bytes in the page and
then hashes another 16 bytes from other data. What would you do
construct a new sgl for it and pass it to the ahash api?

The other thing is crypt_iv_lmk_post also seems to modify the page after
the hash with a  crypto_xor so you'd still need at least one kmap in there.

Logan
