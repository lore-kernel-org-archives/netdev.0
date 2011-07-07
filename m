From: Ian Abbott <abbotti@mev.co.uk>
Subject: Re: [PATCH] lib/checksum.c: optimize do_csum a bit
Date: Thu, 7 Jul 2011 12:32:45 +0100
Message-ID: <4E15995D.6040405@mev.co.uk>
References: <1310037529-30854-1-git-send-email-abbotti@mev.co.uk> <20110707.042925.1609726410655229616.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Ian Abbott <ian.abbott@mev.co.uk>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"arnd@arndb.de" <arnd@arndb.de>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110707.042925.1609726410655229616.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 07/07/11 12:29, David Miller wrote:
> From: Ian Abbott <abbotti@mev.co.uk>
> Date: Thu, 7 Jul 2011 12:18:49 +0100
> 
>> Reduce the number of variables modified by the loop in do_csum() by 1,
>> which seems like a good idea.  On Nios II (a RISC CPU with 3-operand
>> instruction set) it reduces the loop from 7 to 6 instructions, including
>> the conditional branch.
>>
>> Signed-off-by: Ian Abbott <abbotti@mev.co.uk>
> 
> I think you'll overshoot past the end of the buffer when there are
> trailing bytes to handle.
> 
> The whole reason we need the count variable is to handle those
> kinds of cases.

I don't think it does.  That's what the & ~3 was for.

-- 
-=( Ian Abbott @ MEV Ltd.    E-mail: <abbotti@mev.co.uk>        )=-
-=( Tel: +44 (0)161 477 1898   FAX: +44 (0)161 718 3587         )=-
