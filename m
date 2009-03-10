From: Daniel Lezcano <daniel.lezcano@free.fr>
Subject: Re: [RFC 2/4] net: netfilter conntrack - add per-net functionality
 	for DCCP protocol
Date: Tue, 10 Mar 2009 13:43:45 +0100
Message-ID: <49B66081.7010702@free.fr>
References: <20090309181628.109019157@gmail.com>	 <20090309182731.762563452@gmail.com> <49B63EA6.2060802@free.fr>	 <49B6420B.4080309@free.fr>	 <aa79d98a0903100359x5cba797fu9611823b91c64b42@mail.gmail.com>	 <49B65076.6090003@openvz.org> <aa79d98a0903100451r6179ca61l3573cd8ae6e171b7@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Pavel Emelyanov <xemul@openvz.org>, davem@davemloft.net,
	kaber@trash.net, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, adobriyan@gmail.com,
	Cyrill Gorcunov <gorcunov@openvz.org>
To: Cyrill Gorcunov <gorcunov@gmail.com>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <aa79d98a0903100451r6179ca61l3573cd8ae6e171b7@mail.gmail.com>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Cyrill Gorcunov wrote:
> On Tue, Mar 10, 2009 at 2:35 PM, Pavel Emelyanov <xemul@openvz.org> wrote:
> ...
>   
>>>>>>   static int __init nf_conntrack_proto_dccp_init(void)
>>>>>>  {
>>>>>>     int err;
>>>>>>  -    err = nf_conntrack_l4proto_register(&dccp_proto4);
>>>>>> +    err = register_pernet_gen_device(&dccp_net_id, &dccp_net_ops);
>>>>>>
>>>>>>             
>>>> [ cut ]
>>>>         
>>>>> Shouldn't it be register_pernet_gen_subsys ?
>>>>>           
>>> No, I believe. By using  register_pernet_gen_device I'm allowed to
>>> not modify 'struct net' and friends and keep all I need in my own
>>> pointer retrieved thru per-net gen-device id I've registered.
>>>       
>> I believe Daniel means, that we need the register_xxx_get_subsys call
>> for subsystems, rather than devices, that will behave according to the
>> generic net pointers.
>>
>> Daniel, am I right with this suggestion?
>>
>>     
Correct, otherwise that can lead to a kernel panic if you receive a 
packet while the namespace is exiting.
> ...
> Ah, yes, just checked register_pernet_gen_subsys -- it's what I need. Thanks!
>   
You are welcome :)

  -- Daniel
