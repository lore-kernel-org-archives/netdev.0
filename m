From: Vineet Gupta <Vineet.Gupta1@synopsys.com>
Subject: Re: [PATCH] ethernet/arc/arc_emac: Fix huge delays in large file
 copies
Date: Mon, 16 Sep 2013 11:13:48 +0530
Message-ID: <52369A94.5060900@synopsys.com>
References: <1378295235-18928-1-git-send-email-vgupta@synopsys.com> <20130905.142530.732425484460470485.davem@davemloft.net> <522EBBD2.1060003@synopsys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<Alexey.Brodkin@synopsys.com>, <linux-kernel@vger.kernel.org>,
	"stable@vger.kernel.org" <stable@vger.kernel.org>
To: greg Kroah-Hartman <gregkh@linuxfoundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <522EBBD2.1060003@synopsys.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09/10/2013 11:57 AM, Vineet Gupta wrote:
> On 09/05/2013 11:55 PM, David Miller wrote:
>> From: Vineet Gupta <Vineet.Gupta1@synopsys.com>
>> Date: Wed, 4 Sep 2013 17:17:15 +0530
>>
>>> copying large files to a NFS mounted host was taking absurdly large
>>> time.
>>>
>>> Turns out that TX BD reclaim had a sublte bug.
>>>
>>> Loop starts off from @txbd_dirty cursor and stops when it hits a BD
>>> still in use by controller. However when it stops it needs to keep the
>>> cursor at that very BD to resume scanning in next iteration. However it
>>> was erroneously incrementing the cursor, causing the next scan(s) to
>>> fail too, unless the BD chain was completely drained out.
>>>
>>> [ARCLinux]$ ls -l -sh /disk/log.txt
>>>  17976 -rw-r--r--    1 root     root       17.5M Sep  /disk/log.txt
>>>
>>> ========== Before =====================
>>> [ARCLinux]$ time cp /disk/log.txt /mnt/.
>>> real    31m 7.95s
>>> user    0m 0.00s
>>> sys     0m 0.10s
>>>
>>> ========== After =====================
>>> [ARCLinux]$ time cp /disk/log.txt /mnt/.
>>> real    0m 24.33s
>>> user    0m 0.00s
>>> sys     0m 0.19s
>>>
>>> Signed-off-by: Vineet Gupta <vgupta@synopsys.com>
>>
>> Applied.
>>
> 
> Hi Greg,
> 
> This needs a stable backport (3.11).
> Mainline commit 27082ee1b92f4d41e78b85
> 
> Thx,
> -Vineet

Hi Greg,

I didn't spot this one in your stable-queue for 3.11.
Please apply.

Thx,
Vineet
