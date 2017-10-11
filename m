From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH v8 01/20] crypto: change transient busy return code to
 -EAGAIN
Date: Wed, 11 Oct 2017 14:26:51 +0800
Message-ID: <20171011062651.GA18664@gondor.apana.org.au>
References: <1504615144-29770-1-git-send-email-gilad@benyossef.com>
 <1504615144-29770-2-git-send-email-gilad@benyossef.com>
 <20171007030541.GA29421@gondor.apana.org.au>
 <CAOtvUMd=vtju=VJkCYFRrvANbRRYj+95cdgDoMMfBvmPaPbsAA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Mike Snitzer <snitzer@redhat.com>, linux-doc@vger.kernel.org,
 Gary Hook <gary.hook@amd.com>, David Howells <dhowells@redhat.com>,
 device-mapper development <dm-devel@redhat.com>, keyrings@vger.kernel.org,
 linux-ima-devel@lists.sourceforge.net, Alasdair Kergon <agk@redhat.com>,
 Steffen Klassert <steffen.klassert@secunet.com>,
 Boris Brezillon <boris.brezillon@free-electrons.com>,
 Jonathan Corbet <corbet@lwn.net>, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
 Mimi Zohar <zohar@linux.vnet.ibm.com>, "Serge E. Hallyn" <serge@hallyn.com>,
 Tom Lendacky <thomas.lendacky@amd.com>, linux-cifs@vger.kernel.org,
 linux-ima-user@lists.sourceforge.net, Arnaud Ebalard <arno@natisbad.org>,
 linux-raid@vger.kernel.org, linux-fscrypt@vger.kernel.org,
 linux-mediatek@lists.infradead.org, James Morris <james.l.morris@oracle.com>,
 Matthias Brugger <matthias.bgg@gmail.com>, Jaegeuk Kim <jaegeuk@kernel.o
To: Gilad Ben-Yossef <gilad@benyossef.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
Content-Disposition: inline
In-Reply-To: <CAOtvUMd=vtju=VJkCYFRrvANbRRYj+95cdgDoMMfBvmPaPbsAA@mail.gmail.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

On Sat, Oct 07, 2017 at 10:51:42AM +0300, Gilad Ben-Yossef wrote:
> On Sat, Oct 7, 2017 at 6:05 AM, Herbert Xu <herbert@gondor.apana.org.au> wrote:
> > On Tue, Sep 05, 2017 at 03:38:40PM +0300, Gilad Ben-Yossef wrote:
> >>
> >> diff --git a/crypto/algif_hash.c b/crypto/algif_hash.c
> >> index 5e92bd2..3b3c154 100644
> >> --- a/crypto/algif_hash.c
> >> +++ b/crypto/algif_hash.c
> >> @@ -39,6 +39,20 @@ struct algif_hash_tfm {
> >>       bool has_key;
> >>  };
> >>
> >> +/* Previous versions of crypto_* ops used to return -EBUSY
> >> + * rather than -EAGAIN to indicate being tied up. The in
> >> + * kernel API changed but we don't want to break the user
> >> + * space API. As only the hash user interface exposed this
> >> + * error ever to the user, do the translation here.
> >> + */
> >> +static inline int crypto_user_err(int err)
> >> +{
> >> +     if (err == -EAGAIN)
> >> +             return -EBUSY;
> >> +
> >> +     return err;
> >
> > I don't see the need to carry along this baggage.  Does anyone
> > in user-space actually rely on EBUSY?
> 
> 
> I am not aware of anyone who does. I was just trying to avoid
> changing the user ABI.
> 
> Shall I roll a new revision without this patch?

Yes please.  I'd rather not carry this around for eternity unless
it was actually required.

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
