From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] sctp: Avoid out-of-bounds reads from address
 storage
Date: Wed, 23 Aug 2017 22:35:10 -0700 (PDT)
Message-ID: <20170823.223510.265877259463283617.davem@davemloft.net>
References: <7763d91bcf14744e49f09fc4bec0fb22c097774f.1502384055.git.sbrivio@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        stable@vger.kernel.org, lucien.xin@gmail.com, vyasevich@gmail.com,
        nhorman@tuxdriver.com, linux-sctp@vger.kernel.org
To: sbrivio@redhat.com
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <7763d91bcf14744e49f09fc4bec0fb22c097774f.1502384055.git.sbrivio@redhat.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stefano Brivio <sbrivio@redhat.com>
Date: Wed, 23 Aug 2017 13:27:13 +0200

> inet_diag_msg_sctp{,l}addr_fill() and sctp_get_sctp_info() copy
> sizeof(sockaddr_storage) bytes to fill in sockaddr structs used
> to export diagnostic information to userspace.
> 
> However, the memory allocated to store sockaddr information is
> smaller than that and depends on the address family, so we leak
> up to 100 uninitialized bytes to userspace. Just use the size of
> the source structs instead, in all the three cases this is what
> userspace expects. Zero out the remaining memory.
> 
> Unused bytes (i.e. when IPv4 addresses are used) in source
> structs sctp_sockaddr_entry and sctp_transport are already
> cleared by sctp_add_bind_addr() and sctp_transport_new(),
> respectively.
> 
> Noticed while testing KASAN-enabled kernel with 'ss':
 ...
> This fixes CVE-2017-7558.
> 
> References: https://bugzilla.redhat.com/show_bug.cgi?id=1480266
> Fixes: 8f840e47f190 ("sctp: add the sctp_diag.c file")
> Cc: <stable@vger.kernel.org> # 4.7+
> Cc: Xin Long <lucien.xin@gmail.com>
> Cc: Vlad Yasevich <vyasevich@gmail.com>
> Cc: Neil Horman <nhorman@tuxdriver.com>
> Signed-off-by: Stefano Brivio <sbrivio@redhat.com>

Applied and queued up for -stable.

Do not put "stable@kernel..." into networking patch submissions.
For networking, I handle the stable submissions by hand myself.

Thank you.
