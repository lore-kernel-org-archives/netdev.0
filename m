From: Steve Wise <swise@opengridcomputing.com>
Subject: Re: [ofa-general] Re: [PATCH 06/21] RDS: Connection handling
Date: Tue, 27 Jan 2009 10:28:48 -0600
Message-ID: <497F3640.6070600@opengridcomputing.com>
References: <1233022678-9259-1-git-send-email-andy.grover@oracle.com>	<1233022678-9259-7-git-send-email-andy.grover@oracle.com>	<20090127133418.GH2646@ioremap.net>
	<200901271447.29377.oliver@neukum.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Evgeniy Polyakov <zbr@ioremap.net>, rdreier@cisco.com,
	rds-devel@oss.oracle.com, general@lists.openfabrics.org,
	netdev@vger.kernel.org
To: Oliver Neukum <oliver@neukum.org>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <200901271447.29377.oliver@neukum.org>
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

Oliver Neukum wrote:
> Am Tuesday 27 January 2009 14:34:19 schrieb Evgeniy Polyakov:
>   
>> On Mon, Jan 26, 2009 at 06:17:43PM -0800, Andy Grover (andy.grover@oracle.com) wrote:
>>     
>>> +static inline int rds_conn_is_sending(struct rds_connection *conn)
>>> +{
>>> +	int ret = 0;
>>> +
>>> +	if (!mutex_trylock(&conn->c_send_lock))
>>> +		ret = 1;
>>> +	else
>>> +		mutex_unlock(&conn->c_send_lock);
>>> +
>>> +	return ret;
>>> +}
>>> +
>>>       
>> This one is eventually invoked under the spin_lock with turned off irqs,
>> which may freeze the machine:
>> rds_for_each_conn_info() -> spin_lock_irqsave(global lock) ->
>> rds_conn_info_visitor() -> rds_conn_info_set() -> rds_conn_is_sending()
>> -> boom.
>>     
>
> Why? This is _trylock. It won't block.
>
>   
mutex_trylock() uses spin_lock_mutex() which has this in the debug version:

DEBUG_LOCKS_WARN_ON(in_interrupt());
