From: "Yankejian (Hackim Yim)" <yankejian@huawei.com>
Subject: Re: [PATCH net-next] net: hns: optimize XGE capability by reducing
 cpu usage
Date: Mon, 7 Dec 2015 16:58:30 +0800
Message-ID: <56654A36.6090106@huawei.com>
References: <1449300749-50275-1-git-send-email-yankejian@huawei.com>
 <20151206.222929.804694720513782203.davem@davemloft.net>
 <1449459120.7356.14.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <lisheng011@huawei.com>, <lipeng321@huawei.com>,
	<salil.mehta@huawei.com>, <huangdaode@hisilicon.com>,
	<xuwei5@hisilicon.com>, <liguozhu@huawei.com>,
	<haifeng.wei@huawei.com>, <yisen.zhuang@huawei.com>,
	<linuxarm@huawei.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
To: Joe Perches <joe@perches.com>, David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1449459120.7356.14.camel@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On 2015/12/7 11:32, Joe Perches wrote:
> On Sun, 2015-12-06 at 22:29 -0500, David Miller wrote:
>> > From: yankejian <yankejian@huawei.com>
>> > Date: Sat, 5 Dec 2015 15:32:29 +0800
>> > 
>>> > > +#if (PAGE_SIZE < 8192)
>>> > > +     if (hnae_buf_size(ring) == HNS_BUFFER_SIZE_2048) {
>>> > > +             truesize = hnae_buf_size(ring);
>>> > > +     } else {
>>> > > +             truesize = ALIGN(size, L1_CACHE_BYTES);
>>> > > +             last_offset = hnae_page_size(ring) - hnae_buf_size(ring);
>>> > > +     }
>>> > > +
>>> > > +#else
>>> > > +             truesize = ALIGN(size, L1_CACHE_BYTES);
>>> > > +             last_offset = hnae_page_size(ring) - hnae_buf_size(ring);
>>> > > +#endif
>> > 
>> > This is not indented properly, and it looks terrible.
> And it makes one curious as to why last_offset isn't set
> in the first block.

Hi Joe,
if hnae_buf_size que equal to HNS_BUFFER_SIZE, last_offset is useless in the routines of this function.
so it is ignored in the first block. thanks for your suggestion.

Best regards,
yankejian
