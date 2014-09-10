From: Ilya Dryomov <ilya.dryomov@inktank.com>
Subject: Re: [PATCH net-next 2/5] ceph: Convert pr_warning to pr_warn
Date: Wed, 10 Sep 2014 16:38:07 +0400
Message-ID: <CALFYKtCiGXhMZ-f0B=TGSNGZCng8NVYWCV-wwOHq3xPdKO+-Kw@mail.gmail.com>
References: <cover.1410322181.git.joe@perches.com>
	<714b7551f5a6ea5e721fed705568a39eeae4623b.1410322181.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, Sage Weil <sage@inktank.com>,
	"David S. Miller" <davem@davemloft.net>,
	Ceph Development <ceph-devel@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Joe Perches <joe@perches.com>
Return-path: <ceph-devel-owner@vger.kernel.org>
In-Reply-To: <714b7551f5a6ea5e721fed705568a39eeae4623b.1410322181.git.joe@perches.com>
Sender: ceph-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 10, 2014 at 8:17 AM, Joe Perches <joe@perches.com> wrote:
> Use the more common pr_warn.
>
> Other miscellanea:
>
> o Coalesce formats
> o Realign arguments
>
> Signed-off-by: Joe Perches <joe@perches.com>
> ---
>  net/ceph/ceph_common.c | 15 +++++++++------
>  net/ceph/messenger.c   | 19 ++++++++++---------
>  net/ceph/osd_client.c  | 15 +++++++--------
>  net/ceph/osdmap.c      | 20 ++++++++++----------
>  4 files changed, 36 insertions(+), 33 deletions(-)
>
> diff --git a/net/ceph/ceph_common.c b/net/ceph/ceph_common.c
> index 1675021..58fbfe1 100644
> --- a/net/ceph/ceph_common.c
> +++ b/net/ceph/ceph_common.c
> @@ -293,17 +293,20 @@ static int get_secret(struct ceph_crypto_key *dst, const char *name) {
>                 key_err = PTR_ERR(ukey);
>                 switch (key_err) {
>                 case -ENOKEY:
> -                       pr_warning("ceph: Mount failed due to key not found: %s\n", name);
> +                       pr_warn("ceph: Mount failed due to key not found: %s\n",
> +                               name);
>                         break;
>                 case -EKEYEXPIRED:
> -                       pr_warning("ceph: Mount failed due to expired key: %s\n", name);
> +                       pr_warn("ceph: Mount failed due to expired key: %s\n",
> +                               name);
>                         break;
>                 case -EKEYREVOKED:
> -                       pr_warning("ceph: Mount failed due to revoked key: %s\n", name);
> +                       pr_warn("ceph: Mount failed due to revoked key: %s\n",
> +                               name);
>                         break;
>                 default:
> -                       pr_warning("ceph: Mount failed due to unknown key error"
> -                              " %d: %s\n", key_err, name);
> +                       pr_warn("ceph: Mount failed due to unknown key error %d: %s\n",
> +                               key_err, name);
>                 }
>                 err = -EPERM;
>                 goto out;
> @@ -433,7 +436,7 @@ ceph_parse_options(char *options, const char *dev_name,
>
>                         /* misc */
>                 case Opt_osdtimeout:
> -                       pr_warning("ignoring deprecated osdtimeout option\n");
> +                       pr_warn("ignoring deprecated osdtimeout option\n");
>                         break;
>                 case Opt_osdkeepalivetimeout:
>                         opt->osd_keepalive_timeout = intval;
> diff --git a/net/ceph/messenger.c b/net/ceph/messenger.c
> index b2f571d..a7203be 100644
> --- a/net/ceph/messenger.c
> +++ b/net/ceph/messenger.c
> @@ -1937,11 +1937,11 @@ static int process_banner(struct ceph_connection *con)
>                    sizeof(con->peer_addr)) != 0 &&
>             !(addr_is_blank(&con->actual_peer_addr.in_addr) &&
>               con->actual_peer_addr.nonce == con->peer_addr.nonce)) {
> -               pr_warning("wrong peer, want %s/%d, got %s/%d\n",
> -                          ceph_pr_addr(&con->peer_addr.in_addr),
> -                          (int)le32_to_cpu(con->peer_addr.nonce),
> -                          ceph_pr_addr(&con->actual_peer_addr.in_addr),
> -                          (int)le32_to_cpu(con->actual_peer_addr.nonce));
> +               pr_warn("wrong peer, want %s/%d, got %s/%d\n",
> +                       ceph_pr_addr(&con->peer_addr.in_addr),
> +                       (int)le32_to_cpu(con->peer_addr.nonce),
> +                       ceph_pr_addr(&con->actual_peer_addr.in_addr),
> +                       (int)le32_to_cpu(con->actual_peer_addr.nonce));
>                 con->error_msg = "wrong peer at address";
>                 return -1;
>         }
> @@ -2302,7 +2302,7 @@ static int read_partial_message(struct ceph_connection *con)
>
>                 BUG_ON(!con->in_msg ^ skip);
>                 if (con->in_msg && data_len > con->in_msg->data_length) {
> -                       pr_warning("%s skipping long message (%u > %zd)\n",
> +                       pr_warn("%s skipping long message (%u > %zd)\n",
>                                 __func__, data_len, con->in_msg->data_length);
>                         ceph_msg_put(con->in_msg);
>                         con->in_msg = NULL;
> @@ -2712,7 +2712,7 @@ static bool con_sock_closed(struct ceph_connection *con)
>         CASE(OPEN);
>         CASE(STANDBY);
>         default:
> -               pr_warning("%s con %p unrecognized state %lu\n",
> +               pr_warn("%s con %p unrecognized state %lu\n",
>                         __func__, con, con->state);
>                 con->error_msg = "unrecognized con state";
>                 BUG();
> @@ -2828,8 +2828,9 @@ static void con_work(struct work_struct *work)
>   */
>  static void con_fault(struct ceph_connection *con)
>  {
> -       pr_warning("%s%lld %s %s\n", ENTITY_NAME(con->peer_name),
> -              ceph_pr_addr(&con->peer_addr.in_addr), con->error_msg);
> +       pr_warn("%s%lld %s %s\n",
> +               ENTITY_NAME(con->peer_name),
> +               ceph_pr_addr(&con->peer_addr.in_addr), con->error_msg);

Just wondering, why did you move ENITITY_NAME argument to the next
line?  I see you are doing this pretty consistently.  Is this a style
guideline or something?

Thanks,

                Ilya
