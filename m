From: Zhi Yong Wu <zwu.kernel@gmail.com>
Subject: Re: [PATCH v2 2/2] tun: update file current position
Date: Sat, 7 Dec 2013 04:32:20 +0800
Message-ID: <CAEH94LgGv79e7ACzb_zF97p2iEPYFwxuQSHpoYf5_s-YMZsn0A@mail.gmail.com>
References: <1386320930-11285-1-git-send-email-zwu.kernel@gmail.com>
	<1386320930-11285-2-git-send-email-zwu.kernel@gmail.com>
	<20131206.124500.1976272290413710707.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org,
	linux-kernel mlist <linux-kernel@vger.kernel.org>,
	Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20131206.124500.1976272290413710707.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Dec 7, 2013 at 1:45 AM, David Miller <davem@davemloft.net> wrote:
> From: Zhi Yong Wu <zwu.kernel@gmail.com>
> Date: Fri,  6 Dec 2013 17:08:50 +0800
>
>> From: Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
>>
>> Signed-off-by: Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
>
> Also applied and queued up for -stable, thanks.
>
> I noticed in these two cases that that min_t() adjustment of 'ret'
> seems strange.  I can't understand why it's needed.
>
> If, for example, tun_do_read() really did read more than 'len'
> bytes:
>
> 1) That would write past the end of the buffer.
>
> 2) Writing a different value to the ->ki_pos would mean
>    that ->ki_pos is now inaccurate.
>
> Unless someone can explain why the min_t() is needed, we should remove
> it.
Yes, from my side, it seems to be impossible that ret is bigger than
let or total_len.
So we also remove the branch "if (ret > total_len) {...}" in xxx_rcvmsg().
If you hope to submit the patch for this, please let me know, thanks.


-- 
Regards,

Zhi Yong Wu
