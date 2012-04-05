From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: pull request: batman-adv 2012-04-05
Date: Thu, 05 Apr 2012 19:15:02 -0400 (EDT)
Message-ID: <20120405.191502.146577400943539254.davem@davemloft.net>
References: <1333622342-6128-1-git-send-email-ordex@autistici.org>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
	<b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
To: ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <1333622342-6128-1-git-send-email-ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
List-Unsubscribe: <https://lists.open-mesh.org/mm/options/b.a.t.m.a.n>,
	<mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.open-mesh.org/pipermail/b.a.t.m.a.n>
List-Post: <mailto:b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <https://lists.open-mesh.org/mm/listinfo/b.a.t.m.a.n>,
	<mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=subscribe>
Sender: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Errors-To: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Antonio Quartulli <ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
Date: Thu,  5 Apr 2012 12:38:46 +0200

> This is my first pull-request, so I hope I've done everything in the right way,
> but please, fell free to blame me so that I can learn more :-)
> 
> I would like to propose the following changes for net-next/3.5. The first patch
> just adds a new maintainer for batman-adv; patches from 2 to 5 are cleanups
> and little fixes to make batman-adv re-use kernel defines/structures (ETH_ALEN
> and bitmap); patch 6 increases the default value of the "hop_penalty" parameter
> in order to encourage batman-adv to choose shorter routes; patches from 7 to 16
> consist in the renewal of the bridge loop avoidance mechanism (aka BLA2).
> BLA2 faces the same problem that STP tries to solve in classical switched
> networks, but in a layer 2 mesh. In this case the problem shows up when the user
> connects two nodes belonging to the same mesh by means of an ethernet bridge.
> It is possible to find much more details about BLA2 in our wiki [1,2,3].
> 
> As you can see its compile option is set to 'y' by default, but simply because
> this mechanism (actually its old version) was already part of the batman-adv
> core, but we decided to possibly let the users choose to remove it whether the
> network permits it and so reduce the binary size.

This series needs work.

1) Comments were added which were formatted like this:

	/* ...
	 * ... */

   Please fix all of these cases up to be:

	/* ...
	 * ...
	 */

2) Whan the bridge loop avoiding code is compiled out, you
   replace them with macros that of all things use varargs
   "..." instead of specifying correctly the arguments.

   In any event these should not be macros, but rather
   inline functions that do nothing, in order to get correct
   type checking.

   
