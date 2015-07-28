From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH net] bridge: mdb: fix delmdb state in the
	notification
Date: Wed, 29 Jul 2015 00:43:21 +0200
Message-ID: <55B80589.4070500@cumulusnetworks.com>
References: <1438081844-18801-1-git-send-email-razor@blackwall.org>
	<CAHA+R7NJod_=R=Hh2Mz7nMiTxCMv=E4TMLsn2uOrS+f9gp+uHQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	"bridge@lists.linux-foundation.org" <bridge@lists.linux-foundation.org>,
	David Miller <davem@davemloft.net>, Cong Wang <amwang@redhat.com>
To: Cong Wang <cwang@twopensource.com>,
	Nikolay Aleksandrov <razor@blackwall.org>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <CAHA+R7NJod_=R=Hh2Mz7nMiTxCMv=E4TMLsn2uOrS+f9gp+uHQ@mail.gmail.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On 07/29/2015 12:38 AM, Cong Wang wrote:
> On Tue, Jul 28, 2015 at 4:10 AM, Nikolay Aleksandrov
> <razor@blackwall.org> wrote:
>> From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
>>
>> Since mdb states were introduced when deleting an entry the state was
>> left as it was set in the delete request from the user which leads to
>> the following output when doing a monitor (for example):
>> $ bridge mdb add dev br0 port eth3 grp 239.0.0.1 permanent
>> (monitor) dev br0 port eth3 grp 239.0.0.1 permanent
>> $ bridge mdb del dev br0 port eth3 grp 239.0.0.1 permanent
>> (monitor) dev br0 port eth3 grp 239.0.0.1 temp
>> ^^^
>> Note the "temp" state in the delete notification which is wrong since
>> the entry was permanent, the state in a delete is always reported as
>> "temp" regardless of the real state of the entry.
>>
> 
> Hmm?
> 
> I think it is iproute2 who forgets to set entry->state when deleting it?
> 
>                 } else if (strcmp(*argv, "permanent") == 0) {
>                         if (cmd == RTM_NEWMDB)
>                                 entry.state |= MDB_PERMANENT;
> 
> Kernel simply returns what you pass to it.
> 
> Please fix iproute2.
> 

Hi Cong,
Please read the full commit log, I've explained that the state is not honored in the kernel
so it doesn't matter if iproute2 sets the correct state that you give on the command
line, that is if I give it "temp" and the entry is permanent - it will still get
deleted and the notification will have the wrong state as "temp" because I've set
it, while this way it'll at least return the correct state of the entry being deleted.
Again I'm saying that I chose this solution over a check for the entry state because
it may break some user-space tools that rely on the behaviour that the state is
not checked in the kernel.

Cheers,
 Nik
