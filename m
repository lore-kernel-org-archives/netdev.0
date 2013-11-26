From: Shawn Landden <shawn@churchofgit.com>
Subject: Re: [PATCH] update consumers of MSG_MORE to recognize MSG_SENDPAGE_NOTLAST
Date: Mon, 25 Nov 2013 18:43:56 -0800
Message-ID: <CAJusiZV-NeiAfW=O-eUDPhW-BmTh5fNTn6R86axt22=mg-HDnA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	linux-fsdevel@vger.kernel.org, viro@zeniv.linux.org.uk,
	Shawn Landden <shawnlandden@gmail.com>,
	linux-crypto@vger.kernel.org, netdev@vger.kernel.org,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Tom Herbert <therbert@google.com>,
	"David S. Miller" <davem@davemloft.net>, stable@vger.kernel.org,
	Richard Weinberger <richard@nod.at>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 25, 2013 at 7:36 AM, Shawn Landden <shawn@churchofgit.com> wrote:
> Commit 35f9c09fe (tcp: tcp_sendpages() should call tcp_push() once)
> added an internal flag MSG_SENDPAGE_NOTLAST, similar to
> MSG_MORE.
>
> algif_hash, algif_skcipher, and udp used MSG_MORE from tcp_sendpages()
> and need to see the new flag as identical to MSG_MORE.
>
> This fixes sendfile() on AF_ALG.
>
> v3: also fix udp
>
> Cc: Tom Herbert <therbert@google.com>
> Cc: Eric Dumazet <eric.dumazet@gmail.com>
> Cc: David S. Miller <davem@davemloft.net>
> Cc: <stable@vger.kernel.org> # 3.4.x + 3.2.x
> Reported-and-tested-by: Shawn Landden <shawnlandden@gmail.com>
> Original-patch: Richard Weinberger <richard@nod.at>
> Signed-off-by: Shawn Landden <shawn@churchofgit.com>

>May I ask why you took over the my patch without even CC'in me nor
>replying to the original
>thread "[PATCH] pipe_to_sendpage: Ensure that MSG_MORE is set if we
>set MSG_SENDPAGE_NOTLAST"?
>You are acting very rude.
Not CCing you was an oversight.

>The discussion at the original thread is not done.
>Does skcipher_sendpage() really also need fixing? or UDP?

UDP needs it or it will send out packets mid-sendfile. skcipher needs
it or it will produce incorrect
output like hash.
>I didn't send another patch because I'm waiting for Eric's answer first.
Eric forgot to update consumers internal consumers of MSG_MORE when he created
this distinction in sendpage. That became clear when he first
responded. Changing this where the consumers are makes sense. I just
want this bug fixed, feel free to send your next version.

>Thanks,
>//richard

-Shawn
