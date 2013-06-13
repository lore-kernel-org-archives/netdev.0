From: Pravin Shelar <pshelar-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH net-next 2/4] openvswitch: Simplify interface
	ovs_flow_metadata_from_nlattrs()
Date: Thu, 13 Jun 2013 09:13:22 -0700
Message-ID: <CALnjE+rX-RbMMMW3K=do4Lk+wNM8fx0yXqshbnUf-ShXxX2H1Q@mail.gmail.com>
References: <1371077824-19718-1-git-send-email-pshelar@nicira.com>
	<CAEP_g=9wNpx4P1anDo1v0996z1=VqJrMkNQsb87CGfHfNxb9FA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org" <dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <CAEP_g=9wNpx4P1anDo1v0996z1=VqJrMkNQsb87CGfHfNxb9FA-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
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

On Wed, Jun 12, 2013 at 7:52 PM, Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org> wrote:
> On Wed, Jun 12, 2013 at 3:57 PM, Pravin B Shelar <pshelar-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org> wrote:
>> diff --git a/net/openvswitch/flow.c b/net/openvswitch/flow.c
>> index b15321a..150f181 100644
>> --- a/net/openvswitch/flow.c
>> +++ b/net/openvswitch/flow.c
>> @@ -1122,10 +1122,9 @@ int ovs_flow_from_nlattrs(struct sw_flow_key *swkey, int *key_lenp,
>>
>>  /**
>>   * ovs_flow_metadata_from_nlattrs - parses Netlink attributes into a flow key.
>> - * @priority: receives the skb priority
>> - * @mark: receives the skb mark
>> - * @in_port: receives the extracted input port.
>> - * @key: Netlink attribute holding nested %OVS_KEY_ATTR_* Netlink attribute
>> + * @flow: Receives extracted in_port, priority, tun_key and skb_mark.
>> + * @key_len: Length of key in @flow.  Used for calculating flow hash.
>> + * @attr: Netlink attribute holding nested %OVS_KEY_ATTR_* Netlink attribute
>>   * sequence.
>>   *
>>   * This parses a series of Netlink attributes that form a flow key, which must
>> @@ -1133,15 +1132,15 @@ int ovs_flow_from_nlattrs(struct sw_flow_key *swkey, int *key_lenp,
>>   * get the metadata, that is, the parts of the flow key that cannot be
>>   * extracted from the packet itself.
>>   */
>> -int ovs_flow_metadata_from_nlattrs(u32 *priority, u32 *mark, u16 *in_port,
>> -                              const struct nlattr *attr)
>> +int ovs_flow_metadata_from_nlattrs(struct sw_flow *flow, int key_len,
>> +                                  const struct nlattr *attr)
>
> It looks like key_len isn't actually used in this function. Is there
> another piece that you meant to include?

right, It is not required in this patch. will send updated patch.
