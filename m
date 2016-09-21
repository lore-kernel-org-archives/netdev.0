From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] 6pack: fix buffer length mishandling
Date: Tue, 20 Sep 2016 22:51:58 -0400 (EDT)
Message-ID: <20160920.225158.1366025915900844841.davem@davemloft.net>
References: <147431251411.53012.5151201638797223106.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: alan@linux.intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:60080 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755040AbcIUCwB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Sep 2016 22:52:01 -0400
In-Reply-To: <147431251411.53012.5151201638797223106.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alan <alan@linux.intel.com>
Date: Mon, 19 Sep 2016 20:15:24 +0100

> Dmitry Vyukov wrote:
>> different runs). Looking at code, the following looks suspicious -- we
>> limit copy by 512 bytes, but use the original count which can be
>> larger than 512:
>>
>> static void sixpack_receive_buf(struct tty_struct *tty,
>>     const unsigned char *cp, char *fp, int count)
>> {
>>     unsigned char buf[512];
>>     ....
>>     memcpy(buf, cp, count < sizeof(buf) ? count : sizeof(buf));
>>     ....
>>     sixpack_decode(sp, buf, count1);
> 
> With the sane tty locking we now have I believe the following is safe as
> we consume the bytes and move them into the decoded buffer before
> returning.
> 
> Signed-off-by: Alan Cox <alan@linux.intel.com>

Applied to net-next, thanks Alan.
