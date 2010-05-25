From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: Re: [PATCH 22/27] net/dccp: Use memdup_user
Date: Tue, 25 May 2010 13:23:07 +0200
Message-ID: <20100525112307.GA5528@gerrit.erg.abdn.ac.uk>
References: <Pine.LNX.4.64.1005221025040.13021@ask.diku.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>,
	"David S. Miller" <davem@davemloft.net>, dccp@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Julia Lawall <julia@diku.dk>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.1005221025040.13021@ask.diku.dk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

| Signed-off-by: Julia Lawall <julia@diku.dk>
Acked-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>

| 
| ---
|  net/dccp/proto.c |   11 +++--------
|  1 file changed, 3 insertions(+), 8 deletions(-)
| 
| diff --git a/net/dccp/proto.c b/net/dccp/proto.c
| index b03ecf6..f79bcef 100644
| --- a/net/dccp/proto.c
| +++ b/net/dccp/proto.c
| @@ -473,14 +473,9 @@ static int dccp_setsockopt_ccid(struct sock *sk, int type,
|  	if (optlen < 1 || optlen > DCCP_FEAT_MAX_SP_VALS)
|  		return -EINVAL;
|  
| -	val = kmalloc(optlen, GFP_KERNEL);
| -	if (val == NULL)
| -		return -ENOMEM;
| -
| -	if (copy_from_user(val, optval, optlen)) {
| -		kfree(val);
| -		return -EFAULT;
| -	}
| +	val = memdup_user(optval, optlen);
| +	if (IS_ERR(val))
| +		return PTR_ERR(val);
|  
|  	lock_sock(sk);
|  	if (type == DCCP_SOCKOPT_TX_CCID || type == DCCP_SOCKOPT_CCID)
