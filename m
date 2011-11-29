From: Xi Wang <xi.wang@gmail.com>
Subject: Re: [PATCH] sctp: integer overflow in sctp_auth_create_key()
Date: Tue, 29 Nov 2011 02:33:50 -0500
Message-ID: <147F953A-CC69-41FF-ACD4-64E5E2956411@gmail.com>
References: <426D7BA8-ECD0-44D6-A09F-2033F0C825FC@gmail.com> <4ED3AC7D.6090108@hp.com>
Mime-Version: 1.0 (Apple Message framework v1084)
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: linux-kernel@vger.kernel.org, Sridhar Samudrala <sri@us.ibm.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
	security@kernel.org
To: Vladislav Yasevich <vladislav.yasevich@hp.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4ED3AC7D.6090108@hp.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I agree that this is not a security issue if key_len can never get large.

So how about just removing the overflow check at all?

- xi

On Nov 28, 2011, at 10:45 AM, Vladislav Yasevich wrote:
> 
> Hmm.  Yes, this is a more correct check.
> 
> Acked-by: Vlad Yasevich <vladislav.yasevich@hp.com>
> 
> 
> However, I don't think this is a security issue.  As I've written before, this function is
> called from 2 places:
> 
>  1) setsockopt() code path
> 
>  2) sctp_auth_asoc_set_secret() code path
> 
> In case (1), sca_keylength is never going to exceed 65535 since it's
> bounded by a u16 from the user api.  As such, The integer promotion will
> not impact anything and the malloc() will never overflow.
> 
> In case (2), sca_keylength is computed based on the key the user provided
> (MAX_USHORT) and the combination of protocol negotiated data where that
> combination has a max size of 3 * MAX_USHORT (see sctp_auth_make_key_vector()).
> So, even this case, our maximum key length can be 4* MAX_USHORT which still
> will always be below MAX_INT and will not overflow.
> 
> So, I don't think there is big security consideration here, just a bad
> check that just happens to always work.
> 
> -vlad
