From: Julia Lawall <julia@diku.dk>
Subject: question about drivers/isdn/hisax/st5481_init.c
Date: Fri, 13 May 2011 07:53:43 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.1105130748060.9190@ask.diku.dk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: Karsten Keil <isdn@linux-pingi.de>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The function probe_st5481 allocates an adapter value using kzalloc, adds 
it to adapter_list, and then performs various initialization operations, 
which may fail.  adapter_list is a static variable that is never otherwise 
referenced in the file.  There is a list_del that removes the adapter from 
the list in the function disconnect_st5481.  The presence of the adapter 
on the list makes it possibly unsafe to free adapter in the failure cases.

Could the list just be removed, if it is not being used anywhere?

Or if the list should be kept because it is useful or it is planned to be 
useful in the future, could the insertion into the list be moved to the 
end of the function, after the potentially failing operations, so that 
adapter can be freed when a failure occurs?

julia
