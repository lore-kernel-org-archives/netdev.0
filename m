From: Mahesh Bandewar <maheshb@google.com>
Subject: Re: [PATCH net-next v6 2/2] bonding: Simplify the xmit function for
 modes that use xmit_hash
Date: Thu, 2 Oct 2014 22:58:35 +0530
Message-ID: <CAF2d9jhdvkxw_3cm-hXFY1wxy5WVKdnmcNOdRTak_Qx+6NS1sA@mail.gmail.com>
References: <1412152711-12646-1-git-send-email-maheshb@google.com>
 <6356.1412180365@famine> <CAF2d9jioDfj+qmvrQBQcaHnvXbL+Fnsh3-jxwn2KU+zvV=xgJQ@mail.gmail.com>
 <063D6719AE5E284EB5DD2968C1650D6D174A2CF5@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Jay Vosburgh <jay.vosburgh@canonical.com>,
	Veaceslav Falico <vfalico@redhat.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Maciej Zenczykowski <maze@google.com>
To: David Laight <David.Laight@aculab.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f178.google.com ([209.85.220.178]:37632 "EHLO
	mail-vc0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752032AbaJBR24 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Oct 2014 13:28:56 -0400
Received: by mail-vc0-f178.google.com with SMTP id hq12so1667081vcb.23
        for <netdev@vger.kernel.org>; Thu, 02 Oct 2014 10:28:55 -0700 (PDT)
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D174A2CF5@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 2, 2014 at 2:42 PM, David Laight <David.Laight@aculab.com> wrote:
> From: Mahesh Bandewar
>> On Wed, Oct 1, 2014 at 9:49 PM, Jay Vosburgh <jay.vosburgh@canonical.com> wrote:
>> > Mahesh Bandewar <maheshb@google.com> wrote:
> ...
>> >>  * Select aggregation groups, and assign each port for it's aggregetor. The
>> >>  * selection logic is called in the inititalization (after all the handshkes),
>> >>  * and after every lacpdu receive (if selected is off).
>> >>  */
>> >>-static void ad_port_selection_logic(struct port *port)
>> >>+static void ad_port_selection_logic(struct port *port, bool *update_slave_arr)
>> >
>> >         Since this function is void, why not have it return a value
>> > instead of the bool *update_slave_arr?  That would eliminate the need
>> > for some call sites to pass a "dummy" to the function.  This comment
>> > applies to ad_agg_selection_logic and ad_enable_collecting_distributing
>> > as well.
>> >
>> Yes, I had similar discussion with Nik earlier and overloading the
>> return value did not feel clean and future-proof and hence decided to
>> take this approach.
>
> What overload?
> Returning values by reference parameters isn't really a good idea.
> It kills performance and optimisations.
> If you ever need a second return value then solve the problem then.
>
Please show me how much performance we are loosing by taking this
approach... otherwise this argument is bogus!

>         David
>
>
>
