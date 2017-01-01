From: Lorenzo Colitti <lorenzo@google.com>
Subject: Re: [PATCH] net: socket: don't set sk_uid to garbage value in ->setattr()
Date: Sun, 1 Jan 2017 16:57:23 +0900
Message-ID: <CAKD1Yr0=dDgD0em4jqXB8Rd+rpVJPOG7OsRcm-=3xCSQOth1gg@mail.gmail.com>
References: <20161230234232.4221-1-ebiggers3@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        linux-fsdevel@vger.kernel.org, lkml <linux-kernel@vger.kernel.org>,
        Eric Biggers <ebiggers@google.com>
To: Eric Biggers <ebiggers3@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161230234232.4221-1-ebiggers3@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Dec 31, 2016 at 8:42 AM, Eric Biggers <ebiggers3@gmail.com> wrote:
> ->setattr() was recently implemented for socket files to sync the socket
> inode's uid to the new 'sk_uid' member of struct sock.  It does this by
> copying over the ia_uid member of struct iattr.  However, ia_uid is
> actually only valid when ATTR_UID is set in ia_valid, indicating that
> the uid is being changed, e.g. by chown.
> [...]
> -       if (!err) {
> +       if (!err && (iattr->ia_valid & ATTR_UID)) {

Oops. Thanks for fixing this. Unit tested in
https://android-review.googlesource.com/316594 .

Tested-by: Lorenzo Colitti <lorenzo@google.com>
Acked-by: Lorenzo Colitti <lorenzo@google.com>
