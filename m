From: Ulrich Weber <uweber@astaro.de>
Subject: Re: [Vpn-failover] [RFC] IPSEC failover - Netlink part
Date: Tue, 09 Nov 2004 09:55:05 +0100
Message-ID: <419085E9.4060209@astaro.de>
References: <1099045435.2888.47.camel@nienna.balabit> <418A3630.1040900@astaro.de> <418A71DA.2090607@trash.net> <418F4AF9.7050605@astaro.de> <418F9A70.7040400@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: vpn-failover@lists.balabit.hu, netdev@oss.sgi.com,
        ipsec-tools-devel@lists.sourceforge.net
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <418F9A70.7040400@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

|> |> +    NLMSG_LENGTH(sizeof(struct xfrm_usersa_id)),/* UPD SEQ */
|> |>
|> |>
|> | ^^ what about struct xfrm_replay_state ?
|> it's attached as rt attribute, so it should be ok.
|
| But you don't check it's size. You need to include it here or check it
| when you use it.
ok i added the following checkt to ensure the right size.

If i add the size of the xfrm_replay_state struct to the above array, the rt
attribute macros wouldnt work anymore.


Cheers
~ Ulrich

- ----
struct rtattr *rt = xfrma[XFRMA_REPLAY-1];

if( xfrma[XFRMA_REPLAY-1] && (rt->rta_len == (sizeof(struct
xfrm_replay_state) + sizeof(struct rtattr)))) {
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.5 (GNU/Linux)
Comment: Using GnuPG with Thunderbird - http://enigmail.mozdev.org

iD8DBQFBkIXp22t2oTuElzoRAqsnAJ9QlZuU6wBWtmkzcT8aeb9+AL3nfQCfZUeI
EJh0+e8EOS4/HKiP2Ylu02k=
=roZY
-----END PGP SIGNATURE-----
