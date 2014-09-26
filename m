From: Ben Pfaff <blp-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH/RFC repost 2/8] netlink: Allow suppression of
 warnings for duplicate attributes
Date: Fri, 26 Sep 2014 16:55:42 -0700
Message-ID: <20140926235542.GA20493@nicira.com>
References: <1411005311-11752-1-git-send-email-simon.horman@netronome.com>
 <1411005311-11752-3-git-send-email-simon.horman@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Simon Horman <simon.horman-wFxRvT7yatFl57MIdRCFDg@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1411005311-11752-3-git-send-email-simon.horman-wFxRvT7yatFl57MIdRCFDg@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Sender: "dev" <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Id: netdev.vger.kernel.org

On Thu, Sep 18, 2014 at 10:55:05AM +0900, Simon Horman wrote:
> Add a multiple field to struct nl_policy which if set suppresses
> warning of duplicate attributes in nl_parse_nested().
> 
> As is the case without this patch only the last occurrence of an
> attribute is stored in attrs by nl_parse_nested(). As such
> if the multiple field of struct nl_policy is set then it
> is up to the caller to parse the message to extract all the attributes.
> 
> This is in preparation for allowing multiple OVS_SELECT_GROUP_ATTR_BUCKET
> attributes in a nested OVS_ACTION_ATTR_SELECT_GROUP attribute.
> 
> Signed-off-by: Simon Horman <simon.horman-wFxRvT7yatFl57MIdRCFDg@public.gmane.org>

In the other case where we have duplicate attributes, it doesn't make
sense to process them with the policy functions, because we want to
see all of the instances of the duplicate attributes and policy
doesn't allow us to do that.  I'm a little surprised that the new
attributes work differently.  What's the idea?
