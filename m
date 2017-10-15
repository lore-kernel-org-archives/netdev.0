From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH v9 00/20] simplify crypto wait for async op
Date: Sun, 15 Oct 2017 23:38:31 +0800
Message-ID: <20171015153831.GA22867@gondor.apana.org.au>
References: <1508059209-25529-1-git-send-email-gilad@benyossef.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Mike Snitzer <snitzer@redhat.com>, linux-doc@vger.kernel.org,
	Gary Hook <gary.hook@amd.com>,
	David Howells <dhowells@redhat.com>, dm-devel@redhat.com,
	keyrings@vger.kernel.org, linux-ima-devel@lists.sourceforge.net,
	Alasdair Kergon <agk@redhat.com>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	Boris Brezillon <boris.brezillon@free-electrons.com>,
	Jonathan Corbet <corbet@lwn.net>, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	Mimi Zohar <zohar@linux.vnet.ibm.com>,
	"Serge E. Hallyn" <serge@hallyn.com>,
	Tom Lendacky <thomas.lendacky@amd.com>,
	linux-cifs@vger.kernel.org, linux-ima-user@lists.sourceforge.net,
	Arnaud Ebalard <arno@natisbad.org>, linux-fscrypt@vger.kernel.org,
	linux-mediatek@lists.infradead.org,
	James Morris <james.l.morris@oracle.com>,
	Matthias Brugger <matthias.bgg@gmail.com>,
	Jaegeuk Kim <jaegeuk@kernel.org>, linux-arm-kernel@lists.infradead.org,
	Ofir Dra
To: Gilad Ben-Yossef <gilad@benyossef.com>
Return-path: <dm-devel-bounces@redhat.com>
Content-Disposition: inline
In-Reply-To: <1508059209-25529-1-git-send-email-gilad@benyossef.com>
List-Unsubscribe: <https://www.redhat.com/mailman/options/dm-devel>,
	<mailto:dm-devel-request@redhat.com?subject=unsubscribe>
List-Archive: <https://www.redhat.com/archives/dm-devel>
List-Post: <mailto:dm-devel@redhat.com>
List-Help: <mailto:dm-devel-request@redhat.com?subject=help>
List-Subscribe: <https://www.redhat.com/mailman/listinfo/dm-devel>,
	<mailto:dm-devel-request@redhat.com?subject=subscribe>
Sender: dm-devel-bounces@redhat.com
Errors-To: dm-devel-bounces@redhat.com
List-Id: netdev.vger.kernel.org

On Sun, Oct 15, 2017 at 10:19:45AM +0100, Gilad Ben-Yossef wrote:
>
> Changes from v8:
> - Remove the translation of EAGAIN return code to the
>   previous return code of EBUSY for the user space
>   interface of algif as no one seems to rely on it as
>   requested by Herbert Xu.

Sorry, but I forgot to mention that EAGAIN is not a good value
to use because it's used by the network system calls for other
meanings (interrupted by a signal).

So if we stop doing the translation then we also need to pick
a different value, perhaps E2BIG or something similar that have
no current use within the crypto API or network API.

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
