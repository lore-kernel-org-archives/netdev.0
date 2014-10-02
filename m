From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next v6 2/2] bonding: Simplify the xmit function for
 modes that use xmit_hash
Date: Thu, 2 Oct 2014 09:12:14 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D174A2CF5@AcuExch.aculab.com>
References: <1412152711-12646-1-git-send-email-maheshb@google.com>
 <6356.1412180365@famine>
 <CAF2d9jioDfj+qmvrQBQcaHnvXbL+Fnsh3-jxwn2KU+zvV=xgJQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: Veaceslav Falico <vfalico@redhat.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	"Maciej Zenczykowski" <maze@google.com>
To: 'Mahesh Bandewar' <maheshb@google.com>,
	Jay Vosburgh <jay.vosburgh@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:42830 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751334AbaJBJOK convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Oct 2014 05:14:10 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 21642-01 for <netdev@vger.kernel.org>;
 Thu,  2 Oct 2014 10:14:00 +0100 (BST)
In-Reply-To: <CAF2d9jioDfj+qmvrQBQcaHnvXbL+Fnsh3-jxwn2KU+zvV=xgJQ@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mahesh Bandewar
> On Wed, Oct 1, 2014 at 9:49 PM, Jay Vosburgh <jay.vosburgh@canonical.com> wrote:
> > Mahesh Bandewar <maheshb@google.com> wrote:
...
> >>  * Select aggregation groups, and assign each port for it's aggregetor. The
> >>  * selection logic is called in the inititalization (after all the handshkes),
> >>  * and after every lacpdu receive (if selected is off).
> >>  */
> >>-static void ad_port_selection_logic(struct port *port)
> >>+static void ad_port_selection_logic(struct port *port, bool *update_slave_arr)
> >
> >         Since this function is void, why not have it return a value
> > instead of the bool *update_slave_arr?  That would eliminate the need
> > for some call sites to pass a "dummy" to the function.  This comment
> > applies to ad_agg_selection_logic and ad_enable_collecting_distributing
> > as well.
> >
> Yes, I had similar discussion with Nik earlier and overloading the
> return value did not feel clean and future-proof and hence decided to
> take this approach.

What overload?
Returning values by reference parameters isn't really a good idea.
It kills performance and optimisations.
If you ever need a second return value then solve the problem then.

	David
