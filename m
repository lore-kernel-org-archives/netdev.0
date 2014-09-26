From: David Ahern <lxhacker68-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [RFC PATCH net-next v2 0/5] netns: allow to identify peer netns
Date: Fri, 26 Sep 2014 13:44:47 -0600
Message-ID: <5425C22F.7050301@gmail.com>
References: <1411478430-4989-1-git-send-email-nicolas.dichtel@6wind.com>	<CAHA+R7NnBJ=T3sukzzp-OD2am1nd318XbrXCX84LfSL=nu9ojw@mail.gmail.com>	<54228D87.3070309@6wind.com>	<CAHA+R7NfJYzCsZx0E9YVXKVCQbCm_thPSi+80tix8Z9nVA82Ug@mail.gmail.com>	<5422F0F4.6000709@6wind.com>	<CAHA+R7Ot2kLHb+ne5AW3bFNc87qkFOiEHEyDh9sFrsHqXgrY3g@mail.gmail.com>	<5423D80B.9060500@6wind.com>	<CAHA+R7Ooyam2L-QfP-TjMEZEOqrQcQDxYiebmw760kgEji4G=g@mail.gmail.com>	<54256CCB.4000709@6wind.com>
	<5425BB3E.10700@gmail.com> <87mw9myy4n.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Cong Wang <cwang-xCSkyg8dI+0RB7SZvlqPiA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>,
	Stephen Hemminger <stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87mw9myy4n.fsf-JOvCrm2gF+uungPnsOpG7nhyD016LWXt@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 9/26/14, 1:34 PM, Eric W. Biederman wrote:
> When I wrote the "ip netns" support I never expected that all
> applications would want to run in a specific network namespace.  All
> that is needed is one socket per network namespace.

Sure that is another option. But for a process to create a socket or 
thread in a second namespace it has to run as root -- CAP_SYS_ADMIN is 
needed for setns (or perhaps there is another way to create the socket 
or thread in the namespace).

Second, it still does not address the scalability problem. For example a 
single daemon providing service across 2k namespaces means it needs 2k 
listen sockets. From there a system could have 20, 30 or 50 services 
running. Certainly lighter than a process per namespace, but not even 
close to ideal when talking about something like VRFs.

David
