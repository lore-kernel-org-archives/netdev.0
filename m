From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: Information leak in sco_sock_bind
Date: Wed, 16 Dec 2015 05:19:28 +0100
Message-ID: <37984F86-A7B2-4E34-9301-74C9F90BE0A2@holtmann.org>
References: <CACT4Y+Zi9L5K3JExRLxuLS7FzjnQQth3b9ns-q6QufpyHOXf7Q@mail.gmail.com> <20151215.153926.440589493634712000.davem@davemloft.net>
Mime-Version: 1.0 (Mac OS X Mail 9.2 \(3112\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: dvyukov@google.com, "Gustavo F. Padovan" <gustavo@padovan.org>,
	Johan Hedberg <johan.hedberg@gmail.com>,
	BlueZ development <linux-bluetooth@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>, syzkaller@googlegroups.com,
	kcc@google.com, glider@google.com, sasha.levin@oracle.com,
	edumazet@google.com, keescook@google.com,
	hannes@stressinduktion.org, ursula.braun@de.ibm.com,
	linux-s390@vger.kernel.org, lauro.venancio@openbossa.org,
	aloisio.almeida@openbossa.org, Samuel Ortiz <sameo@linux.intel.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151215.153926.440589493634712000.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave,

>> The following program leads to leak of 6 bytes from kernel stack:
> 
> This should fix it:
> 
> ====================
> [PATCH] bluetooth: Validate socket address length in sco_sock_bind().
> 
> Signed-off-by: David S. Miller <davem@davemloft.net>
> ---
> net/bluetooth/sco.c | 3 +++
> 1 file changed, 3 insertions(+)
> 
> diff --git a/net/bluetooth/sco.c b/net/bluetooth/sco.c
> index fe12966..f52bcbf 100644
> --- a/net/bluetooth/sco.c
> +++ b/net/bluetooth/sco.c
> @@ -526,6 +526,9 @@ static int sco_sock_bind(struct socket *sock, struct sockaddr *addr,
> 	if (!addr || addr->sa_family != AF_BLUETOOTH)
> 		return -EINVAL;
> 
> +	if (addr_len < sizeof(struct sockaddr_sco))
> +		return -EINVAL;
> +
> 	lock_sock(sk);
> 
> 	if (sk->sk_state != BT_OPEN) {

thanks for the patch, but I think we do the same as we do with all the other Bluetooth socket and copy it into cleared stack variable. I have a patch for that and will ask Johan to send a pull request shortly.

Regards

Marcel
