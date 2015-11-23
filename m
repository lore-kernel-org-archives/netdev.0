From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: [RFC PATCH 2/2] Crypto kernel tls socket
Date: Mon, 23 Nov 2015 16:59:06 -0500
Message-ID: <20151123215906.GH30089@oracle.com>
References: <cover.1448299690.git.davejwatson@fb.com>
 <ac7783121ef9442741d67aca5d170f02d851ae03.1448299690.git.davejwatson@fb.com>
 <20151123192730.GB30089@oracle.com>
 <20151123214312.GA2319382@devbig217.prn1.facebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Tom Herbert <tom@herbertland.com>, netdev@vger.kernel.org,
	davem@davemloft.net, Herbert Xu <herbert@gondor.apana.org.au>,
	linux-crypto@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-team@fb.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20151123214312.GA2319382@devbig217.prn1.facebook.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On (11/23/15 13:43), Dave Watson wrote:
> 
> For kcm, opfd is the fd you would pass along in kcm_attach.
> For rds, it looks like you'd want to use opfd as the sock instead of
> the new one created by sock_create_kern in rds_tcp_conn_connect.

I see.

It's something to consider, and it would certainly secure the
RDS header and app data, but TLS by itself may not be
enough- we'd need to protect the TCP control plane as well, and 
at the moment, I'm finding that even using esp-null (or AO, or MD5,
for that matter) means that I lose GSO, and perf tanks. I'll try to
put all my data together for this for netdev 1.1.


> > E.g., if I get a cipher-suite request outside the aes-ni, what would
> > happen (punt to uspace?)
> >
> > --Sowmini
> 
> Right, bind() would fail and you would fallback to uspace.

That's the approach that Solaris KSSL took, back in 1999. It quickly
became obsolete, again more details in netdev 1.1.

--Sowmini
