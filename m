From: Sergei Shtylyov <sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH 03/10] batman-adv: Make DAT capability
	changes atomic
Date: Tue, 11 Aug 2015 22:36:50 +0300
Message-ID: <55CA4ED2.9070207@cogentembedded.com>
References: <1439310948-32426-1-git-send-email-antonio@meshcoding.com>
 <1439310948-32426-4-git-send-email-antonio@meshcoding.com>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
 <b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: quoted-printable
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org,
 Marek Lindner <mareklindner-rVWd3aGhH2z5bpWLKbzFeg@public.gmane.org>
To: Antonio Quartulli <antonio-x4xJYDvStAgysxA8WJXlww@public.gmane.org>, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <1439310948-32426-4-git-send-email-antonio-x4xJYDvStAgysxA8WJXlww@public.gmane.org>
List-Unsubscribe: <https://lists.open-mesh.org/mm/options/b.a.t.m.a.n>,
 <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.open-mesh.org/pipermail/b.a.t.m.a.n/>
List-Post: <mailto:b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <https://lists.open-mesh.org/mm/listinfo/b.a.t.m.a.n>,
 <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=subscribe>
Errors-To: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Sender: "B.A.T.M.A.N" <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Id: netdev.vger.kernel.org

Hello.

On 08/11/2015 07:35 PM, Antonio Quartulli wrote:

> From: Linus L=C3=BCssing <linus.luessing-djzkFPsfvsizQB+pC5nmwQ@public.gmane.org>

> Bitwise OR/AND assignments in C aren't guaranteed to be atomic. One
> OGM handler might undo the set/clear of a specific bit from another
> handler run in between.

> Fix this by using the atomic set_bit()/clear_bit()/test_bit() functions=
.

> Fixes: 17cf0ea455f1 ("batman-adv: tvlv - add distributed arp table cont=
ainer")
> Signed-off-by: Linus L=C3=BCssing <linus.luessing-djzkFPsfvsizQB+pC5nmwQ@public.gmane.org>
> Signed-off-by: Marek Lindner <mareklindner-rVWd3aGhH2z5bpWLKbzFeg@public.gmane.org>
> Signed-off-by: Antonio Quartulli <antonio-x4xJYDvStAgysxA8WJXlww@public.gmane.org>
> ---
>   net/batman-adv/distributed-arp-table.c | 7 ++++---
>   net/batman-adv/types.h                 | 4 ++--
>   2 files changed, 6 insertions(+), 5 deletions(-)

> diff --git a/net/batman-adv/distributed-arp-table.c b/net/batman-adv/di=
stributed-arp-table.c
> index fb54e6a..244dcf6 100644
> --- a/net/batman-adv/distributed-arp-table.c
> +++ b/net/batman-adv/distributed-arp-table.c
[...]
> @@ -453,7 +454,7 @@ static bool batadv_is_orig_node_eligible(struct bat=
adv_dat_candidate *res,
>   	int j;
>
>   	/* check if orig node candidate is running DAT */
> -	if (!(candidate->capabilities & BATADV_ORIG_CAPA_HAS_DAT))
> +	if (!(test_bit(BATADV_ORIG_CAPA_HAS_DAT, &candidate->capabilities)))

    () around the tst_bit() call not needed.

[...]

MBR, Sergei
