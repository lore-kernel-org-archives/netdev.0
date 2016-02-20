From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] unix_diag: fix incorrect sign extension in
 unix_lookup_by_ino
Date: Fri, 19 Feb 2016 23:50:00 -0500 (EST)
Message-ID: <20160219.235000.1109030635629935367.davem@davemloft.net>
References: <20160219012748.GA17251@altlinux.org>
	<CAM_iQpX4c7v2HbMG7cPi3T=HTHeEGhEQTSNS6CxX0tY=7KA4Uw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ldv@altlinux.org, xemul@parallels.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: xiyou.wangcong@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAM_iQpX4c7v2HbMG7cPi3T=HTHeEGhEQTSNS6CxX0tY=7KA4Uw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Fri, 19 Feb 2016 16:21:14 -0800

> On Thu, Feb 18, 2016 at 5:27 PM, Dmitry V. Levin <ldv@altlinux.org> wrote:
>> The value passed by unix_diag_get_exact to unix_lookup_by_ino has type
>> __u32, but unix_lookup_by_ino's argument ino has type int, which is not
>> a problem yet.
>> However, when ino is compared with sock_i_ino return value of type
>> unsigned long, ino is sign extended to signed long, and this results
>> to incorrect comparison on 64-bit architectures for inode numbers
>> greater than INT_MAX.
>>
>> This bug was found by strace test suite.
>>
>> Signed-off-by: Dmitry V. Levin <ldv@altlinux.org>
>> Cc: <stable@vger.kernel.org>
> 
> Fixes: 5d3cae8bc39d ("unix_diag: Dumping exact socket core")
> Acked-by: Cong Wang <xiyou.wangcong@gmail.com>

Applied and queued up for -stable.
