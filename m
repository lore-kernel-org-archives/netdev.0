From: Alexey Khoroshilov <khoroshilov@ispras.ru>
Subject: Re: [PATCH] farsync: fix invalid memory accesses in fst_add_one()
 and fst_init_card()
Date: Tue, 08 Jul 2014 18:40:32 -0400
Message-ID: <53BC7360.6050000@ispras.ru>
References: <1404516950-17900-1-git-send-email-khoroshilov@ispras.ru> <20140708.152057.490185410038470309.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: kevin.curtis@farsite.co.uk, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, ldv-project@linuxtesting.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140708.152057.490185410038470309.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08.07.2014 18:20, David Miller wrote:
> From: Alexey Khoroshilov <khoroshilov@ispras.ru>
> Date: Sat,  5 Jul 2014 03:35:50 +0400
>
>> -                }
>> +			card->nports = i;
>> +			return (card->nports == 0) ? err : 0;
>> +		}
> I don't think this is the right thing to do.
>
> This will cause the caller to not free the IRQ or any of the
> other resources.
My understanding of the existing code is to proceed if at least one port
is available.
So I return error code if no ports available at all, otherwise
initialization continues and can succeed.
If something else goes wrong, all resources are deallocated.

Do you suggest to return error code unconditionally?

--
Alexey
