From: Henrik Nordstrom <hno@marasystems.com>
Subject: Re: udp_recvmsg: possible bug causing infinite hang?
Date: Tue, 12 Oct 2004 10:56:26 +0200 (CEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.61.0410121052140.22884@filer.marasystems.com>
References: <Pine.LNX.4.44.0410121131570.29592-100000@localhost.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: "Chad N. Tindel" <chad@tindel.net>, netdev@oss.sgi.com,
        linux-net@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Nagendra Singh Tomar <nagendra_tomar@adaptec.com>
In-Reply-To: <Pine.LNX.4.44.0410121131570.29592-100000@localhost.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 12 Oct 2004, Nagendra Singh Tomar wrote:

> checksumming. If the standard does not explicitly write anything about the
> guarantee of read/write passing after successful return from select, then
> its fine; but somehow that does not sound very rational.
> If anyone can point to the specific section in the POSIX standard that
> dictates this, it will be of great help.

>From SUSv3 on select():

       A descriptor shall be considered ready for reading when a
       call to an input function with O_NONBLOCK clear would not block,
       whether or not the function would transfer data successfully.
       (The function might return data, an end-of-file indication, or
       an error other than one indicating that it is blocked, and in
       each of these cases the descriptor shall be considered ready
       for reading.)

       A descriptor shall be considered ready for writing when a call
       to an output function with O_NONBLOCK clear would not block,
       whether or not the function would transfer data successfully.


so it seems to me the current Linux implementation is wrong in this 
regard.


Regards
Henrik
