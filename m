From: Andrew Grover <andy.grover@gmail.com>
Subject: ***SPAM*** Re: [ofa-general] Re: [PATCH 06/21] RDS: Connection
	handling
Date: Wed, 28 Jan 2009 19:03:49 -0800
Message-ID: <c0a09e5c0901281903m2d6804e0u94f1e1bc9792b56b@mail.gmail.com>
References: <1233022678-9259-1-git-send-email-andy.grover@oracle.com>
	<1233022678-9259-7-git-send-email-andy.grover@oracle.com>
	<20090127133418.GH2646@ioremap.net>
	<200901271447.29377.oliver@neukum.org>
	<497F3640.6070600@opengridcomputing.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: rds-devel@oss.oracle.com, netdev@vger.kernel.org, rdreier@cisco.com,
	Oliver Neukum <oliver@neukum.org>, general@lists.openfabrics.org,
	Evgeniy Polyakov <zbr@ioremap.net>
To: Steve Wise <swise@opengridcomputing.com>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <497F3640.6070600@opengridcomputing.com>
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
List-Id: netdev.vger.kernel.org

On Tue, Jan 27, 2009 at 8:28 AM, Steve Wise <swise@opengridcomputing.com> wrote:
> Oliver Neukum wrote:
>>
>> Am Tuesday 27 January 2009 14:34:19 schrieb Evgeniy Polyakov:
>>
>>>
>>> On Mon, Jan 26, 2009 at 06:17:43PM -0800, Andy Grover
>>> (andy.grover@oracle.com) wrote:
>>>
>>>>
>>>> +static inline int rds_conn_is_sending(struct rds_connection *conn)
>>>> +{
>>>> +       int ret = 0;
>>>> +
>>>> +       if (!mutex_trylock(&conn->c_send_lock))
>>>> +               ret = 1;
>>>> +       else
>>>> +               mutex_unlock(&conn->c_send_lock);
>>>> +
>>>> +       return ret;
>>>> +}
>>>> +
>>>>
>>>
>>> This one is eventually invoked under the spin_lock with turned off irqs,
>>> which may freeze the machine:
>>> rds_for_each_conn_info() -> spin_lock_irqsave(global lock) ->
>>> rds_conn_info_visitor() -> rds_conn_info_set() -> rds_conn_is_sending()
>>> -> boom.
>>>
>>
>> Why? This is _trylock. It won't block.
>>
>>
>
> mutex_trylock() uses spin_lock_mutex() which has this in the debug version:
>
> DEBUG_LOCKS_WARN_ON(in_interrupt());

What's the best way to fix this?

This is all so rds-info can print out a nice list of connections, and
if they're sending or not. I don't see an easy way to fix this. A
_trylock-like function that didn't grab it would be nice? I can always
just not report this particular bit of info, that actually might be
easiest.

Regards -- Andy
