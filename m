From: Thomas Graf <tgraf-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH v2] linux: Signal datapath that unaligned
 Netlink message can be received
Date: Tue, 17 Dec 2013 19:08:59 +0100
Message-ID: <52B0933B.4030107@redhat.com>
References: <a960865f3ad68da1016f35085c1d84126e92f0a5.1385814128.git.tgraf@redhat.com>
	<CAEP_g=-XN+fHnLpvpQ4A9MadYH4z9uKHcRBa84vOjWaV_K_YDg@mail.gmail.com>
	<52B01EE5.4000704@redhat.com>
	<CAEP_g=8MtthzO=P-JpTE0jH23_EaU+rp4qiwv_Y721vxyZuFTw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: "dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org" <dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <CAEP_g=8MtthzO=P-JpTE0jH23_EaU+rp4qiwv_Y721vxyZuFTw-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

On 12/17/2013 06:49 PM, Jesse Gross wrote:
> I think there's also a potential downgrade issue if we add a new
> feature to the list of capabilities - it won't automatically reset
> since userspace is now using v2 of the netlink protocol. Obviously,
> this isn't an issue yet but it we should make sure that it is
> addressed before there is a release.

>> Defining the NLM_F_REPLACE semantics is non trivial if we want to do
>> more than just update the settings. I will propose this in a follow up
>> patch.
>
> Couldn't userspace just issue an OVS_DP_CMD_SET on start?

Right, that works as well but introduces a small race compared to
NLM_F_REPLACE which would be atomic. I think we can live with that.

I will send a v3 of this patch with dpif-linux changed to issue
OVS_DP_CMD_SET first and fall back to OVS_DP_CMD_NEW if no DP exists.
