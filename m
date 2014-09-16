From: Andrey Dmitrov <andrey.dmitrov@oktetlabs.ru>
Subject: Re: TCP connection will hang in FIN_WAIT1 after closing if zero window
 is advertised
Date: Tue, 16 Sep 2014 13:29:16 +0400
Message-ID: <541802EC.1060308@oktetlabs.ru>
References: <54170FC0.6020907@oktetlabs.ru> <CADVnQym0NmF-Cqz=OEpVBmMAe6T-G1jmoq=fbVWtL7_Ny-wn3w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>,
	"Alexandra N. Kossovsky" <Alexandra.Kossovsky@oktetlabs.ru>,
	Konstantin Ushakov <kostik@oktetlabs.ru>
To: Neal Cardwell <ncardwell@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shelob.oktetlabs.ru ([84.52.89.53]:38868 "EHLO
	shelob.oktetlabs.ru" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752699AbaIPJ3X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Sep 2014 05:29:23 -0400
In-Reply-To: <CADVnQym0NmF-Cqz=OEpVBmMAe6T-G1jmoq=fbVWtL7_Ny-wn3w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 15/09/14 23:43, Neal Cardwell wrote:
> On Mon, Sep 15, 2014 at 12:11 PM, Andrey Dmitrov
> <andrey.dmitrov@oktetlabs.ru> wrote:
>> It is possible to create a lot of connections in the same manner which will be in FIN_WAIT1 state forever.
> ...
>> After ~10 minutes you will see 500 connections in the FIN_WAIT1 state on the host_A:
>> netstat | grep FIN_WAIT1 | wc -l
>> 500
> Thanks for the report. In your tests, have you ever seen the number of
> such connections exceed net.ipv4.tcp_max_orphans?
>
> Can you set net.ipv4.tcp_max_orphans to a low value and verify that it
> limits the number of such connections? AFAICT it should.
I tried to set net.ipv4.tcp_max_orphans to 100, it limits the 
connections number. As I saw net.ipv4.tcp_max_orphans can be exceeded, 
but for a short time. Maximum connections number in FIN_WAIT1 state was 
196, after that it was decreased rather fast to ~100.

Thanks,
Andrey
